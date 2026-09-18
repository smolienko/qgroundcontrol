import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView
import QGroundControl.FlightMap

Item {
    id: _root

    property var parentToolInsets               // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets:   _toolInsets // These are the insets for your custom overlay additions
    property var mapControl

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real   _toolsMargin:   ScreenTools.defaultFontPixelWidth * 0.75
    property real   _fontSize:      ScreenTools.defaultFontPixelHeight * 0.85

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    QGCToolInsets {
        id:                     _toolInsets
        leftEdgeTopInset:       parentToolInsets.leftEdgeTopInset
        leftEdgeCenterInset:    parentToolInsets.leftEdgeCenterInset
        leftEdgeBottomInset:    parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset:      parentToolInsets.rightEdgeTopInset
        rightEdgeCenterInset:   parentToolInsets.rightEdgeCenterInset
        rightEdgeBottomInset:   parentToolInsets.rightEdgeBottomInset
        topEdgeLeftInset:       parentToolInsets.topEdgeLeftInset
        topEdgeCenterInset:     parentToolInsets.topEdgeCenterInset
        topEdgeRightInset:      parentToolInsets.topEdgeRightInset
        bottomEdgeLeftInset:    parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset:  parentToolInsets.bottomEdgeCenterInset
        bottomEdgeRightInset:   parentToolInsets.bottomEdgeRightInset
    }

    // 1. Авиагоризонт по центру экрана над видео
    QGCAttitudeWidget {
        id:                 attitudeWidget
        anchors.centerIn:   parent
        size:               ScreenTools.defaultFontPixelHeight * 12
        vehicle:            _activeVehicle
        showPitch:          true
        showHeading:        true
        visible:            true
    }

    // 2. Индикатор скорости (слева от авиагоризонта)
    Rectangle {
        id:                     speedPanel
        anchors.right:          attitudeWidget.left
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth * 2
        anchors.verticalCenter: attitudeWidget.verticalCenter
        width:                  ScreenTools.defaultFontPixelWidth * 10
        height:                 ScreenTools.defaultFontPixelHeight * 3
        color:                  Qt.rgba(0, 0, 0, 0.5)
        radius:                 ScreenTools.defaultFontPixelWidth * 0.5
        border.color:           "#00FF00"
        border.width:           1
        visible:                true

        ColumnLayout {
            anchors.centerIn:   parent
            spacing:            2

            QGCLabel {
                Layout.alignment:   Qt.AlignHCenter
                text:               qsTr("SPEED")
                color:              "#00FF00"
                font.pixelSize:     _fontSize * 0.7
                font.bold:          true
            }

            QGCLabel {
                Layout.alignment:   Qt.AlignHCenter
                text:               _activeVehicle && _activeVehicle.groundSpeed && !isNaN(_activeVehicle.groundSpeed.value) ?
                                        _activeVehicle.groundSpeed.value.toFixed(1) + " " + QGroundControl.unitsConversion.appSettingsSpeedUnitsString : "0.0"
                color:              "#00FF00"
                font.pixelSize:     _fontSize
                font.bold:          true
            }
        }
    }

    // 3. Индикатор высоты (справа от авиагоризонта)
    Rectangle {
        id:                     altitudePanel
        anchors.left:           attitudeWidget.right
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * 2
        anchors.verticalCenter: attitudeWidget.verticalCenter
        width:                  ScreenTools.defaultFontPixelWidth * 10
        height:                 ScreenTools.defaultFontPixelHeight * 3
        color:                  Qt.rgba(0, 0, 0, 0.5)
        radius:                 ScreenTools.defaultFontPixelWidth * 0.5
        border.color:           "#00FF00"
        border.width:           1
        visible:                true

        ColumnLayout {
            anchors.centerIn:   parent
            spacing:            2

            QGCLabel {
                Layout.alignment:   Qt.AlignHCenter
                text:               qsTr("ALT")
                color:              "#00FF00"
                font.pixelSize:     _fontSize * 0.7
                font.bold:          true
            }

            QGCLabel {
                Layout.alignment:   Qt.AlignHCenter
                text:               _activeVehicle && _activeVehicle.altitudeRelative && !isNaN(_activeVehicle.altitudeRelative.value) ?
                                        _activeVehicle.altitudeRelative.value.toFixed(1) + " " + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString : "0.0"
                color:              "#00FF00"
                font.pixelSize:     _fontSize
                font.bold:          true
            }
        }
    }
}
