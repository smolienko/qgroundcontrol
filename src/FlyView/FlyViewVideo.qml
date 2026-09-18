import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightMap

Item {
    id: _root

    property Item pipView
    property Item pipState: videoPipState

    PipState {
        id:         videoPipState
        pipView:    _root.pipView
        isDark:     true

        onWindowAboutToOpen: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onWindowAboutToClose: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onStateChanged: {
            if (pipState.state !== pipState.fullState) {
                QGroundControl.videoManager.fullScreen = false
            }
        }
    }

    Timer {
        id:           videoStartDelay
        interval:     2000;
        running:      false
        repeat:       false
        onTriggered:  QGroundControl.videoManager.startVideo()
    }

    //-- Video Streaming
    FlightDisplayViewVideo {
        id:             videoStreaming
        anchors.fill:   parent
        useSmallFont:   _root.pipState.state !== _root.pipState.fullState
        visible:        QGroundControl.videoManager.isStreamSource || QGroundControl.videoManager.isUvc
    }

    QGCLabel {
        text: qsTr("Double-click to exit full screen")
        font.pointSize: ScreenTools.largeFontPointSize
        visible: QGroundControl.videoManager.fullScreen
        anchors.centerIn: parent

        onVisibleChanged: {
            if (visible) {
                labelAnimation.start()
            }
        }

        PropertyAnimation on opacity {
            id: labelAnimation
            duration: 10000
            from: 1.0
            to: 0.0
            easing.type: Easing.InExpo
        }
    }

    OnScreenGimbalController {
        id:                      onScreenGimbalController
        anchors.fill:            parent
        cameraTrackingEnabled:   !!(videoStreaming._camera && videoStreaming._camera.trackingEnabled)
    }

    OnScreenCameraTrackingController {
        id:                      cameraTrackingController
        anchors.fill:            parent
        camera:                  videoStreaming._camera
        videoWidth:              videoStreaming.getWidth()
        videoHeight:             videoStreaming.getHeight()
    }

    MouseArea {
        id:                         flyViewVideoMouseArea
        anchors.fill:               parent
        enabled:                    pipState.state === pipState.fullState

        property real _pressX:      0
        property real _pressY:      0
        property bool _dragging:    false
        property bool _doubleClicked: false
        readonly property real _dragThreshold: 10

        // Defer single-click handling so a double-click (fullscreen toggle) doesn't also
        // fire an unintended gimbal click-to-point/tracking command on its first click.
        Timer {
            id:         singleClickTimer
            interval:   Qt.styleHints.mouseDoubleClickInterval
            repeat:     false

            property real clickX: 0
            property real clickY: 0

            onTriggered: {
                onScreenGimbalController.mouseClicked(clickX, clickY)
                cameraTrackingController.mouseClicked(clickX, clickY)
            }
        }

        onDoubleClicked: {
            // Fires on the second press of a double-click. The second release still emits
            // onReleased, so flag it to prevent re-arming the single-click timer.
            _doubleClicked = true
            singleClickTimer.stop()
            QGroundControl.videoManager.fullScreen = !QGroundControl.videoManager.fullScreen
        }

        onPressed: (mouse) => {
            _pressX = mouse.x
            _pressY = mouse.y
            _dragging = false
            // Clear any stale flag (e.g. double-click followed by drag releases through the
            // drag branch without consuming it). Safe: pressed is emitted before doubleClicked.
            _doubleClicked = false
        }

        onPositionChanged: (mouse) => {
            if (!_dragging && (Math.abs(mouse.x - _pressX) >= _dragThreshold || Math.abs(mouse.y - _pressY) >= _dragThreshold)) {
                _dragging = true
                onScreenGimbalController.mouseDragStart(_pressX, _pressY)
                cameraTrackingController.mouseDragStart(_pressX, _pressY)
            }
            if (_dragging) {
                onScreenGimbalController.mouseDragPositionChanged(mouse.x, mouse.y)
                cameraTrackingController.mouseDragPositionChanged(mouse.x, mouse.y)
            }
        }

        onReleased: (mouse) => {
            if (_dragging) {
                onScreenGimbalController.mouseDragEnd()
                cameraTrackingController.mouseDragEnd(mouse.x, mouse.y)
            } else if (_doubleClicked) {
                // Second release of a double-click - fullscreen toggle already handled
                _doubleClicked = false
            } else {
                singleClickTimer.clickX = mouse.x
                singleClickTimer.clickY = mouse.y
                singleClickTimer.restart()
            }
            _dragging = false
        }
    }

    ProximityRadarVideoView {
        anchors.fill:   parent
        vehicle:        QGroundControl.multiVehicleManager.activeVehicle
    }

    ObstacleDistanceOverlayVideo {
        id: obstacleDistance
        showText: pipState.state === pipState.fullState
    }

    //-- HUD Telemetry Overlay (Attitude, Speed, Altitude) directly over video stream
    Item {
        id: videoHudOverlay
        anchors.fill: parent
        z: 10
        visible: true

        property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

        QGCAttitudeWidget {
            id: attitudeWidget
            anchors.centerIn: parent
            size: ScreenTools.defaultFontPixelHeight * 12
            vehicle: videoHudOverlay._activeVehicle
            showPitch: true
            showHeading: true
            visible: true
        }

        // Индикатор скорости (слева от авиагоризонта)
        Rectangle {
            id: speedPanel
            anchors.right: attitudeWidget.left
            anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 2
            anchors.verticalCenter: attitudeWidget.verticalCenter
            width: ScreenTools.defaultFontPixelWidth * 10
            height: ScreenTools.defaultFontPixelHeight * 3
            color: Qt.rgba(0, 0, 0, 0.5)
            radius: ScreenTools.defaultFontPixelWidth * 0.5
            border.color: "#00FF00"
            border.width: 1
            visible: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                QGCLabel {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("SPEED")
                    color: "#00FF00"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.6
                    font.bold: true
                }

                QGCLabel {
                    Layout.alignment: Qt.AlignHCenter
                    text: videoHudOverlay._activeVehicle && videoHudOverlay._activeVehicle.groundSpeed && !isNaN(videoHudOverlay._activeVehicle.groundSpeed.value) ?
                            videoHudOverlay._activeVehicle.groundSpeed.value.toFixed(1) + " " + QGroundControl.unitsConversion.appSettingsSpeedUnitsString : "0.0"
                    color: "#00FF00"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.85
                    font.bold: true
                }
            }
        }

        // Индикатор высоты (справа от авиагоризонта)
        Rectangle {
            id: altitudePanel
            anchors.left: attitudeWidget.right
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 2
            anchors.verticalCenter: attitudeWidget.verticalCenter
            width: ScreenTools.defaultFontPixelWidth * 10
            height: ScreenTools.defaultFontPixelHeight * 3
            color: Qt.rgba(0, 0, 0, 0.5)
            radius: ScreenTools.defaultFontPixelWidth * 0.5
            border.color: "#00FF00"
            border.width: 1
            visible: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                QGCLabel {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("ALT")
                    color: "#00FF00"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.6
                    font.bold: true
                }

                QGCLabel {
                    Layout.alignment: Qt.AlignHCenter
                    text: videoHudOverlay._activeVehicle && videoHudOverlay._activeVehicle.altitudeRelative && !isNaN(videoHudOverlay._activeVehicle.altitudeRelative.value) ?
                            videoHudOverlay._activeVehicle.altitudeRelative.value.toFixed(1) + " " + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString : "0.0"
                    color: "#00FF00"
                    font.pixelSize: ScreenTools.defaultFontPixelHeight * 0.85
                    font.bold: true
                }
            }
        }
    }
}
