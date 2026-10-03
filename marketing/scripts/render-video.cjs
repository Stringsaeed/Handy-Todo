// Render src/video.html frame by frame and mux it with the generated soundtrack.
// Outputs:
//   out/video/app-preview-886x1920.mp4  App Store app preview (6.9"/6.5" iPhone), 30 fps, H.264 + AAC
//   out/video/promo-1080x1920.mp4       Same cut for social and the web
const path = require("path");
const fs = require("fs");
const { execFileSync } = require("child_process");
const { chromium } = require("playwright-core");

const root = path.resolve(__dirname, "..");
const build = path.join(root, "build");
const timeline = JSON.parse(fs.readFileSync(path.join(root, "src/video-timeline.json"), "utf8"));
const targets = [
  ["app-preview-886x1920", 886],
  ["promo-1080x1920", 1080],
];
const only = process.argv[2];
const ffmpeg = (...args) => execFileSync("ffmpeg", ["-v", "error", "-y", ...args], { stdio: "inherit" });

// 1. Normalize the variable-frame-rate simulator takes to 30 fps stills.
//    The cache is rebuilt whenever a take is newer than its extracted frames.
for (const take of ["takeA", "takeB", "takeC"]) {
  const dir = path.join(build, "frames", take);
  const clip = path.join(root, "clips", `${take}.mp4`);
  if (fs.existsSync(dir) && fs.statSync(dir).mtimeMs >= fs.statSync(clip).mtimeMs) continue;
  fs.rmSync(dir, { recursive: true, force: true });
  fs.mkdirSync(dir, { recursive: true });
  ffmpeg("-i", clip, "-vf", "fps=30,scale=1100:-2", "-q:v", "2", path.join(dir, "%05d.jpg"));
}

// 2. Soundtrack.
execFileSync("python3", [path.join(__dirname, "make-audio.py")], { stdio: "inherit" });

(async () => {
  const browser = await chromium.launch({ channel: "chrome", args: ["--allow-file-access-from-files"] });
  for (const [name, width] of targets) {
    if (only && !name.includes(only)) continue;
    const dir = path.join(build, name);
    fs.rmSync(dir, { recursive: true, force: true });
    fs.mkdirSync(dir, { recursive: true });
    const page = await browser.newPage({ viewport: { width, height: 1920 }, deviceScaleFactor: 1 });
    await page.goto("file://" + path.join(root, "src/video.html"));
    await page.waitForFunction(() => window.READY === true, null, { timeout: 60000 });

    const frames = Math.round(timeline.duration * timeline.fps);
    for (let f = 0; f < frames; f++) {
      await page.evaluate((t) => window.render(t), f / timeline.fps);
      await page.screenshot({ path: path.join(dir, `${String(f).padStart(5, "0")}.png`) });
      if (f % 60 === 0) process.stdout.write(`\r${name}: frame ${f}/${frames}`);
    }
    process.stdout.write(`\r${name}: ${frames} frames rendered\n`);
    await page.close();

    // 3. Encode: H.264 High, yuv420p, 30 fps, stereo AAC 256 kbps at 48 kHz.
    const out = path.join(root, "out/video", `${name}.mp4`);
    fs.mkdirSync(path.dirname(out), { recursive: true });
    ffmpeg("-framerate", String(timeline.fps), "-i", path.join(dir, "%05d.png"), "-i", path.join(build, "audio.wav"),
      "-c:v", "libx264", "-profile:v", "high", "-level", "4.2", "-pix_fmt", "yuv420p", "-crf", "14", "-preset", "slow",
      "-r", String(timeline.fps), "-af", "alimiter=limit=0.84:level=false", "-c:a", "aac", "-b:a", "256k", "-ar", "48000", "-ac", "2", "-shortest", "-movflags", "+faststart", out);
    console.log("wrote", path.relative(root, out));
  }
  await browser.close();
})();
