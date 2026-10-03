# handy

A SwiftUI to-do app for iPhone and iPad. Keep tasks in three priority levels, with compact lists, inline task creation, Boris typography, optional task sounds and haptics, and small and large Home Screen widgets.

## Run locally

Open `HandyTodo.xcodeproj` in Xcode and choose the shared `handy` scheme. The app and widget support iOS 17 or later. No third-party runtime dependencies are required.

For a simulator build without signing:

```sh
xcodebuild -project HandyTodo.xcodeproj -scheme handy \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/handy-build CODE_SIGNING_ALLOWED=NO build
```

For a device build, select your development team for both handy and HandyWidgets. Register and enable the `group.com.stringsaeed.handy.todo` App Group for both bundle identifiers. If you change the group identifier, update both entitlement files and `Shared/WidgetSnapshot.swift`. The app's existing CloudKit container is `iCloud.com.stringsaeed.handy.todo`; configure your own container when building under another team.

## Widgets and storage

The app uses SwiftData with the existing CloudKit container. It opens the original `Application Support/HandyTodo.sqlite` store with a matching `TodoItem` schema, preserving task fields, IDs, and CloudKit metadata. The nullable stored properties remain unchanged for compatibility; the UI treats a missing completion flag as unfinished. Handy exports a task snapshot to App Group defaults when SwiftData query results change and on scene transitions. The widget reads that snapshot and refreshes through WidgetKit. It shows unfinished tasks in Primary, Secondary, then Tertiary order. Widgets open the app when tapped. WidgetKit controls when refreshes appear on the Home Screen.

Add a widget by editing the Home Screen and searching for handy. Both small and large sizes are available.

## Fonts and sounds

- Boris by Giulia Boggio is used for app text. Its supplied license is in `HandyTodo/Fonts/Boris-License.txt`, with the original document preserved in `OpenSource License.rtfd`.
- Full font licenses and credits are also available in the app's Settings. Font licenses apply independently of the app source.
- Feedback sounds are original generated tones. Regenerate them with `python3 scripts/generate-sounds.py`. Sounds respect silent mode; haptics require a supported physical device. Both can be switched off in Settings.

## Manual verification

Create a task in each priority. Empty or whitespace-only titles must not save. Complete and reopen a task, swipe to delete, and relaunch to verify persistence. Open the Boris font license in Settings and check the feedback toggles. Add both widget sizes, then add, finish, and delete tasks in the app to check their snapshots. Check iPhone and iPad layouts, dark appearance, larger text, and Reduce Motion. Verify sound and haptics on an iPhone.

## Storage migration regression test

Run `scripts/test-storage-migration.sh` on a Mac with Xcode. It creates a disposable Core Data store using the original model fixture, opens it twice with the production SwiftData model, and verifies all task fields and IDs. It also checks nullable values, duplicate titles, Unicode text, priority queries, creation, completion, undo, deletion, and persistence after reopening. Core Data is used only in the regression test, not in the app.

Before shipping, also test an upgrade from the released app on a signed-in physical device and confirm CloudKit sync between devices. Local simulator checks do not verify CloudKit's production schema or remote sync.

## App icon

The layered app icon is `HandyTodo/HandyIcon.icon`. Open it in Apple Icon Composer to edit the paper layers, checkmark, materials, and appearance variants. Xcode compiles this source as the app icon.

## Interface icons

Custom interface icons come from the supplied `Design/InterfaceIcons.svg`, whose source credits Arrow by QuiverAI. Run `python3 scripts/extract-interface-icons.py` to regenerate the individual vector image sets. The original paths are preserved; SwiftUI tints the assets for light and dark appearance.

Feedback icons morph between on and off outlines, sampled from the supplied SVG. Regenerate the geometry with `python3 scripts/generate-feedback-morph.py`. Reduce Motion disables this animation. The interface and task display use lowercase text; existing stored task titles and category keys remain intact.

## Random task

Tap the shuffle icon to pick an unfinished task across all priorities. The do-now card lets you finish it, pick another, or dismiss the suggestion. Repeated picks avoid the current task when another unfinished task exists. An empty list shows an all-clear message.
