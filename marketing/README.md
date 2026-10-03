# handy marketing

App Store screenshots and the app preview video. Everything is built from real simulator captures, Oregano, the app palette, the layered app icon, the interface icons in `Assets.xcassets`, and handy's own feedback sounds.

## Deliverables

| File | Use |
| --- | --- |
| `out/screenshots/iphone-6.9/*.png` | iPhone 6.9" screenshots, 1320 × 2868. App Store Connect scales them for smaller iPhones. |
| `out/screenshots/ipad-13/*.png` | iPad 13" screenshots, 2064 × 2752. |
| `out/video/app-preview-886x1920.mp4` | App preview for 6.9" and 6.5" iPhones. 24 s, 30 fps, H.264, stereo AAC at 256 kbps. |
| `out/video/promo-1080x1920.mp4` | The same cut for social and the web. |

## Regenerate

```sh
cd marketing
npm install                 # playwright-core; rendering uses the installed Google Chrome
npm run screenshots         # optional filter: npm run screenshots -- 03-do-now
npm run video               # renders both sizes; needs ffmpeg and python3
```

- `src/screenshots.html` holds the layouts and copy. `src/video.html` holds the video timeline, and `src/video-timeline.json` holds the clip time maps, tap points, and sound cues.
- `scripts/make-audio.py` builds the 120 BPM soundtrack with the standard library. The arpeggio uses the same E5 and B5 sine timbre as handy's completion chime, and the mix includes `complete.wav` and `delete.wav`, timed to the on-screen completions and keystrokes.

## Recapturing the app

`raw/` holds full-resolution simulator screenshots, and `clips/` holds the screen recordings.

1. Build with simulator signing, so the iCloud entitlement is embedded. An unsigned build (`CODE_SIGNING_ALLOWED=NO`) can't open the SwiftData CloudKit store and stays on a blank screen.
   ```sh
   xcodebuild -project HandyTodo.xcodeproj -scheme handy -destination 'generic/platform=iOS Simulator' \
     -derivedDataPath /tmp/handy-build CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= build
   ```
2. Set a clean status bar: `xcrun simctl status_bar <udid> override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4`.
3. Launch handy once so it creates its store, quit it, then seed the demo tasks with `python3 scripts/seed-simulator.py <udid>`. Add `--more` on iPad and `--empty` for a blank list.
4. Record with `xcrun simctl io <udid> recordVideo --codec=h264 <file>`. Leave a second or two of activity at the end, because the last frames are dropped when recording stops.

Screenshots were captured on iPhone 18 Pro Max and iPad Pro 13-inch (M5) simulators.
