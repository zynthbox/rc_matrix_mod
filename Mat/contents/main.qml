/* -*- coding: utf-8 -*-
******************************************************************************
ZYNTHIAN PROJECT: Zynthian Qt GUI

Main Class and Program for Zynthian GUI

Copyright (C) 2021 Marco Martin <mart@kde.org>

******************************************************************************

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

For a full copy of the GNU General Public License see the LICENSE.txt file.

******************************************************************************
*/

import "." as Here
import QtGraphicalEffects 1.15
import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.4
import QtQuick.Particles 2.15
import io.zynthbox.ui 1.0 as Zynthian
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

QQC2.Pane {
    id: root

    property bool debugMode: false
    readonly property string currentEngineId: zynqtgui.curlayerEngineId
    readonly property var selectedChannel: applicationWindow().selectedChannel
    property color brightColor1: "#B100E8"
    property color brightColor2: "#e500a4"
    property color textColor: "white"
    property var cuiaCallback: function(cuia) {
        return _loader.item.cuiaCallback(cuia);
    }
    readonly property var synthMap: {
        "ZBP_SYNTH_00008": {
            "cutoff": ["DCF1_CUTOFF", "DCF2_CUTOFF"],
            "resonance": ['DCF1_RESO', 'DCF2_RESO'],
            "filterAttack": ['DCF1_ATTACK', 'DCF2_ATTACK'],
            "filterRelease": ['DCF1_RELEASE', 'DCF2_RELEASE'],
            "filterType": ['DCF1_TYPE', 'DCF2_TYPE'],
            "ampAttack": ['DCA1_ATTACK', 'DCA2_ATTACK'],
            "ampRelease": ['DCA1_RELEASE', 'DCA2_RELEASE']
        },
        "ZBP_SYNTH_00012": {
            "cutoff": ["cutoff"],
            "resonance": ['resonance'],
            "filterAttack": ['filterattack'],
            "filterRelease": ['filterrelease'],
            "filterType": ['filterenvamount'],
            "ampAttack": ['attack'],
            "ampRelease": ['release']
        },
        "ZBP_SYNTH_00009": {
            "cutoff": ["cutoff"],
            "resonance": ['resonance'],
            "filterAttack": ['fil_attack'],
            "filterRelease": ['fil_release'],
            "filterType": [],
            "ampAttack": ['amp_attack'],
            "ampRelease": ['amp_release']
        },
        "ZBP_SYNTH_00011": {
            "cutoff": ["filter cutoff"],
            "resonance": ['filter resonance'],
            "filterAttack": [],
            "filterRelease": [],
            "filterType": [],
            "ampAttack": [],
            "ampRelease": []
        },
        "ZBP_SYNTH_00003": {
            "cutoff": ["flt_hp_cutoff_upper", "flt_hp_cutoff_lower"],
            "resonance": [],
            "filterAttack": [],
            "filterRelease": [],
            "filterType": [],
            "ampAttack": [],
            "ampRelease": []
        },
        "ZBP_SYNTH_00006": {
            "cutoff": ["DCF1_CUTOFF"],
            "resonance": ['DCF1_RESO'],
            "filterAttack": ['DCF1_ATTACK'],
            "filterRelease": ['DCF1_RELEASE'],
            "filterType": ['DCF1_TYPE'],
            "ampAttack": ['DCA1_ATTACK'],
            "ampRelease": ['DCA1_RELEASE']
        },
        "ZBP_SYNTH_00001": {
            "cutoff": ["cutoff"],
            "resonance": ['resonance'],
            "filterType": [],
            "filterAttack": []
        },
        "ZBP_SYNTH_00004": {
            "cutoff": ["cutoff"],
            "resonance": ['resonance'],
            "filterAttack": ['filterattack'],
            "filterRelease": ['filterrelease'],
            "filterType": ['filtertype'],
            "ampAttack": ['ampattack'],
            "ampRelease": ['amprelease']
        },
        "ZBP_SYNTH_00002": {
            "cutoff": ["filter_cutoff"],
            "resonance": ['filter_resonance'],
            "filterAttack": ['filter_attack'],
            "filterRelease": ['filter_release'],
            "filterType": [],
            "ampAttack": ['attack'],
            "ampRelease": ['release']
        },
        "ZBP_SYNTH_00013": {
            "cutoff": ["a_filter1_cutoff", "a_filter2_cutoff", "b_filter1_cutoff", "b_filter2_cutoff"],
            "resonance": ['a_filter1_resonance', 'a_filter2_resonance', 'b_filter1_resonance', 'b_filter2_resonance'],
            "filterType": ['a_filter1_type', 'a_filter2_type', 'b_filter1_type', 'b_filter2_type'],
            "filterAttack": ['a_env1_attack', 'a_env2_attack'],
            "filterRelease": ['a_env1_release', 'a_env2_release']
        },
        "ZBP_SYNTH_00000": {
            "cutoff": ["cutoff"],
            "resonance": ['res'],
            "filterAttack": [],
            "filterRelease": [],
            "filterType": ['filter'],
            "ampAttack": ['adsr_a', 'adsr2_a'],
            "ampRelease": ['adsr_r', 'adsr2_r']
        }
    }

    function update() {
        _loader.active = false;
        _loader.active = true;
    }

    objectName: "MatMod"

    Connections {
        target: zynqtgui.control
        onAll_controlsChanged: {
            update();
        }
    }

    contentItem: QQC2.Control {
        enabled: root.currentEngineId != null
        padding: 10

        background: Item {
            PlasmaCore.FrameSvgItem {
                id: svgBg4

                readonly property real leftPadding: fixedMargins.left
                readonly property real rightPadding: fixedMargins.right
                readonly property real topPadding: fixedMargins.top
                readonly property real bottomPadding: fixedMargins.bottom

                anchors.fill: parent
                imagePath: "widgets/tracks-background"
                colorGroup: PlasmaCore.Theme.ViewColorGroup
            }

        }

        contentItem: Loader {
            id: _loader

            // asynchronous: true
            sourceComponent: Item {
                function cuiaCallback(cuia) {
                    switch (cuia) {
                    case "SELECT_UP":
                    case "SELECT_DOWN":
                        return true;
                    case "NAVIGATE_LEFT":
                    case "NAVIGATE_RIGHT":
                        return true;
                    case "KNOB0_UP":
                        return true;
                    case "KNOB0_DOWN":
                        return true;
                    case "KNOB1_UP":
                    case "KNOB1_DOWN":
                    case "KNOB2_UP":
                    case "KNOB2_DOWN":
                        return true;
                    case "KNOB3_UP":
                        return true;
                    case "KNOB3_DOWN":
                        return true;
                    case "SWITCH_SELECT_SHORT":
                    case "SWITCH_SELECT_BOLD":
                        return true;
                    default:
                        return false;
                    }
                }

                ColumnLayout {
                    anchors.fill: parent

                    RowLayout {
                        Layout.fillWidth: true

                        QQC2.Label {
                            text: "MatPad"
                            font.capitalization: Font.AllUppercase
                            font.weight: Font.ExtraBold
                            font.family: "Hack"
                            font.pointSize: 20
                            Layout.alignment: Qt.AlignTop

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.debugMode = !root.debugMode
                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        QQC2.Label {
                            text: zynqtgui.curlayerEngineName
                            Layout.alignment: Qt.AlignTop
                            // font.capitalization: Font.AllUppercase
                            font.weight: Font.ExtraBold
                            font.family: "Hack"
                            font.pointSize: 20
                        }

                    }

                    Rectangle {
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 300 + Kirigami.Units.gridUnit * 2
                        Layout.alignment: Qt.AlignCenter
                        color: Kirigami.Theme.backgroundColor
                        radius: 10

                        RowLayout {
                            anchors.right: parent.left
                            anchors.rightMargin: Kirigami.Units.gridUnit * 2
                            height: parent.height
                            spacing: ZUI.Theme.sectionSpacing

                            Rectangle {
                                implicitWidth: 8
                                Layout.fillHeight: true
                                radius: 5
                                color: Kirigami.Theme.backgroundColor
                                border.color: Qt.darker(color, 1.5)

                                Rectangle {
                                    radius: parent.radius
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 1
                                    height: (_multiCutoffController.value / _multiCutoffController.to) * parent.height
                                    color: root.brightColor2
                                }

                                QQC2.Label {
                                    text: "C"
                                    anchors.margins: 6
                                    anchors.top: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.pointSize: 8
                                }

                            }

                            Rectangle {
                                implicitWidth: 8
                                Layout.fillHeight: true
                                radius: 5
                                color: Kirigami.Theme.backgroundColor
                                border.color: Qt.darker(color, 1.5)

                                Rectangle {
                                    radius: parent.radius
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 1
                                    height: (_multiResController.value / _multiResController.to) * parent.height
                                    color: root.brightColor2
                                }

                                QQC2.Label {
                                    text: "R"
                                    anchors.margins: 6
                                    anchors.top: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.pointSize: 8
                                }

                            }

                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: ZUI.Theme.spacing

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                                Layout.maximumHeight: Kirigami.Units.gridUnit * 2

                                QQC2.Label {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    text: "Filter"
                                    horizontalAlignment: Qt.AlignHCenter
                                }

                                QQC2.ToolButton {
                                    Layout.fillHeight: true
                                    // text: "Lock"
                                    icon.name: checked ? "lock" : "unlock"
                                    checked: _padControl.lockValues
                                    onClicked: _padControl.lockValues = !_padControl.lockValues
                                }

                            }

                            QQC2.Control {
                                // Text {
                                //     color: "white"
                                //     anchors.centerIn: parent
                                //     text: _area.xp + " / " + _area.yp + " //\n " + _multiCutoffController.value + " =  " + _multiCutoffController.from + "/" + _multiCutoffController.to +"\n"+ _multiResController.value + " =  " + _multiResController.from + "/" + _multiResController.to
                                // }

                                id: _padControl

                                property bool lockValues: true

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                rightPadding: _dot.width
                                bottomPadding: _dot.height

                                background: Rectangle {
                                    color: root.brightColor2
                                    radius: 10
                                    opacity: 0.7

                                    Item {
                                        anchors.fill: parent
                                        anchors.margins: Kirigami.Units.gridUnit * 2

                                        Rectangle {
                                            width: 1
                                            height: parent.height
                                            color: root.textColor
                                            opacity: 0.7
                                            anchors.centerIn: parent
                                        }

                                        Rectangle {
                                            width: 1
                                            height: parent.height
                                            color: root.textColor
                                            opacity: 0.2
                                            x: parent.width * 0.25
                                        }

                                        Rectangle {
                                            width: 1
                                            height: parent.height
                                            color: root.textColor
                                            opacity: 0.2
                                            x: parent.width * 0.75
                                        }

                                        Rectangle {
                                            height: 1
                                            width: parent.width
                                            color: root.textColor
                                            opacity: 0.5
                                            anchors.centerIn: parent
                                        }

                                        Rectangle {
                                            height: 1
                                            width: parent.width
                                            color: root.textColor
                                            opacity: 0.2
                                            y: parent.width * 0.25
                                        }

                                        Rectangle {
                                            height: 1
                                            width: parent.width
                                            color: root.textColor
                                            opacity: 0.2
                                            y: parent.width * 0.75
                                        }

                                    }

                                    QQC2.Label {
                                        text: "Cutoff"
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        opacity: 0.8
                                        anchors.margins: Kirigami.Units.smallSpacing + 6
                                    }

                                    Item {
                                        id: _parentLabel

                                        width: Kirigami.Units.gridUnit
                                        height: _label.implicitWidth
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: Kirigami.Units.smallSpacing + 6

                                        QQC2.Label {
                                            id: _label

                                            text: "Resonance"
                                            opacity: 0.8
                                            anchors.top: parent.bottom
                                            elide: Text.ElideMiddle

                                            transform: Rotation {
                                                origin.x: 0
                                                origin.y: 0
                                                angle: -90
                                            }

                                        }

                                    }

                                }

                                contentItem: Item {
                                    id: _area

                                    property int l_cp: _multiCutoffController.value_default
                                    property int l_rp: _multiResController.value_default
                                    property int cp: Math.round(((_multiCutoffController.value) / _multiCutoffController.to) * _area.width)
                                    property int rp: Math.round(((_multiResController.value) / _multiResController.to) * _area.width)
                                    property int xp: Math.round((_dot.x * 100) / _area.width)
                                    property int yp: Math.round((_dot.y * 100) / _area.height)

                                    function updateValues() {
                                        if (_drag.active) {
                                            _multiCutoffController.setValue((_drag.xPos / _area.width) * _multiCutoffController.to);
                                            _multiResController.setValue((_drag.yPos / _area.height) * _multiResController.to);
                                        }
                                    }

                                    Item {
                                        id: _dot

                                        width: 20
                                        height: 20
                                        x: _drag.active ? Math.min(_area.width, Math.max(0, _drag.centroid.position.x)) : _area.cp
                                        y: _drag.active ? Math.min(_area.height, Math.max(0, _drag.centroid.position.y)) : _area.rp

                                        Rectangle {
                                            color: root.textColor
                                            anchors.fill: parent
                                            radius: height
                                            anchors.margins: 2
                                        }

                                        Item {
                                            anchors.fill: parent
                                            visible: zynqtgui.sketchpad.isMetronomeRunning

                                            ParticleSystem {
                                                id: sys

                                                running: zynqtgui.sketchpad.isMetronomeRunning
                                            }

                                            Emitter {
                                                id: emitter

                                                anchors.centerIn: parent
                                                system: sys
                                                emitRate: 120 // Particles per second
                                                lifeSpan: 2000 // Lasts 2 seconds
                                                lifeSpanVariation: 500
                                                size: _drag.active ? 40 : 24
                                                sizeVariation: 20

                                                velocity: AngleDirection {
                                                    angleVariation: 360
                                                    magnitude: _drag.active ? 60 : 20
                                                }

                                            }

                                            ImageParticle {
                                                system: sys
                                                source: "qrc:///particleresources/glowdot.png" // Uses default Qt resource
                                                color: Qt.lighter(root.brightColor2, 2)
                                                redVariation: 0 // Becomes more "white" as red and green increase
                                                greenVariation: 0.1
                                                blueVariation: 0.2 // Keeps some blue dominance
                                            }

                                        }

                                    }

                                    Here.MultiController {
                                        id: _multiCutoffController

                                        controllersIds: root.currentEngineId != null && root.synthMap[root.currentEngineId] != null && root.synthMap[root.currentEngineId].cutoff ? root.synthMap[root.currentEngineId].cutoff : []
                                    }

                                    Here.MultiController {
                                        id: _multiResController

                                        controllersIds: root.currentEngineId != null && root.synthMap[root.currentEngineId] != null && root.synthMap[root.currentEngineId].resonance ? root.synthMap[root.currentEngineId].resonance : []
                                    }

                                    DragHandler {
                                        id: _drag

                                        readonly property real xPos: _drag.centroid.position.x
                                        readonly property real yPos: _drag.centroid.position.y

                                        target: null
                                        xAxis.maximum: _area.width
                                        xAxis.minimum: 0
                                        yAxis.maximum: _area.height
                                        yAxis.minimum: 0
                                        onXPosChanged: _area.updateValues()
                                        onYPosChanged: _area.updateValues()
                                        onActiveChanged: {
                                            if (!active) {
                                                if (_padControl.lockValues) {
                                                    _area.l_cp = _multiCutoffController.value;
                                                    _area.l_rp = _multiResController.value;
                                                } else {
                                                    _multiCutoffController.setValue(_area.l_cp);
                                                    _multiResController.setValue(_area.l_rp);
                                                }
                                            }
                                        }
                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
