# QGroundControl Custom Development History & Context

## Summary of Completed Work
1. **Repository Setup:**
   - QGroundControl repository cloned into: `C:\Users\user\AndroidStudioProjects\qgroundcontrol`
   - Linked to GitHub fork: `https://github.com/smolienko/qgroundcontrol.git`

2. **UI Modifications for Video Telemetry Overlay (Attitude, Speed, Altitude):**
   - **`src/FlyView/FlyViewCustomLayer.qml`**: Configured custom HUD layer with central `QGCAttitudeWidget` and side panels for Speed (`groundSpeed.value`) and Altitude (`altitudeRelative.value`). Removed `_activeVehicle !== null` visibility constraint so the overlay is always visible even when disconnected.
   - **`src/FlyView/FlyViewVideo.qml`**: Integrated HUD overlay directly into the video stream widget so telemetry appears over video in fullscreen, PIP, and window modes, ensuring visibility at all times (`visible: true`, `z: 10`).

3. **CI/CD & Android APK Build:**
   - Configured GitHub Actions build workflow (`.github/workflows/android.yml`).
   - Active workflow run: `https://github.com/smolienko/qgroundcontrol/actions/runs/35229848737`

## Guidelines for AI Agent in Future Chat Sessions
When resuming work in `qgroundcontrol` project window:
1. Read `AGENTS.md` and `CODING_STYLE.md` before making edits.
2. Follow QGC coding rules (Fact System, null-checks on `_activeVehicle`, `ScreenTools` font sizing, `qsTr` localization).
3. Commit message format: Conventional Commits (`feat(...)`, `fix(...)`).
