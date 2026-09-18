# QGroundControl Custom Development History & Context

## Summary of Completed Work
1. **Repository Setup:**
   - QGroundControl repository cloned into: `C:\Users\user\AndroidStudioProjects\qgroundcontrol`
   - Linked to GitHub fork: `https://github.com/smolienko/qgroundcontrol.git`

2. **UI Modifications for Video Telemetry Overlay (Attitude, Speed, Altitude):**
   - **`src/FlyView/FlyViewCustomLayer.qml`**: Removed HUD elements from custom layer so nothing is displayed over the main map screen.
   - **`src/FlyView/FlyViewVideo.qml`**: Placed HUD overlay exclusively on the video screen. Replaced default `QGCAttitudeWidget` with a clean, transparent-background green horizon line and central crosshair (`#00FF00`) with pitch/roll animations, flanked by green Speed and Altitude panels.

3. **CI/CD & Android APK Build:**
   - Configured GitHub Actions build workflow (`.github/workflows/android.yml`).
   - Active workflow run: `https://github.com/smolienko/qgroundcontrol/actions/runs/35229848737`

## Guidelines for AI Agent in Future Chat Sessions
When resuming work in `qgroundcontrol` project window:
1. Read `AGENTS.md` and `CODING_STYLE.md` before making edits.
2. Follow QGC coding rules (Fact System, null-checks on `_activeVehicle`, `ScreenTools` font sizing, `qsTr` localization).
3. Commit message format: Conventional Commits (`feat(...)`, `fix(...)`).
