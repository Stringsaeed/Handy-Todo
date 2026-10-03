// Render every <section data-name> in src/screenshots.html to out/screenshots/<device>/<name>.png
// at exact App Store pixel sizes (iPhone 6.9": 1320×2868, iPad 13": 2064×2752).
const path = require("path");
const fs = require("fs");
const { chromium } = require("playwright-core");

const root = path.resolve(__dirname, "..");
const only = process.argv[2];

(async () => {
  const browser = await chromium.launch({ channel: "chrome", args: ["--allow-file-access-from-files"] });
  const page = await browser.newPage({ viewport: { width: 2100, height: 3000 }, deviceScaleFactor: 1 });
  await page.goto("file://" + path.join(root, "src/screenshots.html"));
  await page.waitForFunction(() => window.READY === true, null, { timeout: 30000 });

  for (const section of await page.locator("section[data-name]").all()) {
    const name = await section.getAttribute("data-name");
    if (only && !name.includes(only)) continue;
    const file = path.join(root, "out/screenshots", name.replace("iphone/", "iphone-6.9/").replace("ipad/", "ipad-13/") + ".png");
    fs.mkdirSync(path.dirname(file), { recursive: true });
    await section.screenshot({ path: file, animations: "disabled" });
    console.log("wrote", path.relative(root, file));
  }
  await browser.close();
})();
