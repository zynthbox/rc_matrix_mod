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

import QtQuick 2.15
import QtQml 2.15
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import "." as Here
import io.zynthbox.ui 1.0 as Zynthian
import QtGraphicalEffects 1.15

QQC2.Pane {
    id: root
    objectName: "MatMod"
    property bool debugMode: false
    readonly property string currentEngineId: zynqtgui.curlayerEngineId
    readonly property var selectedChannel : applicationWindow().selectedChannel
    // readonly property string currentSlotPos: root.selectedChannel.id + "/" +root.selectedChannel.selectedSlot.value + "/" +currentEngineId
    // readonly property var curLayer: zynqtgui.curLayer
    focus: true

    property var cuiaCallback: function(cuia) {
        return _loader.item.cuiaCallback(cuia);
    }

    Connections{
        target: zynqtgui.control
        onAll_controlsChanged :
        {
            update()
        }
    }

    function update() {
        _loader.active = false
        _loader.active = true
    }

    readonly property var synthMap : {
        'ZBP_SYNTH_00008': {
            'cutoff': ["DCF1_CUTOFF","DCF2_CUTOFF"],
            'resonance': ['DCF1_RESO','DCF2_RESO'],
            'filterAttack' : ['DCF1_ATTACK', 'DCF2_ATTACK'],
            'filterRelease' : ['DCF1_RELEASE', 'DCF2_RELEASE'],
            'filterType' : ['DCF1_TYPE', 'DCF2_TYPE'],
            'ampAttack' : ['DCA1_ATTACK', 'DCA2_ATTACK'],
            'ampRelease' : ['DCA1_RELEASE', 'DCA2_RELEASE']},
        'ZBP_SYNTH_00012': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterAttack': ['filterattack'],
            'filterRelease': ['filterrelease'],
            'filterType' : ['filterenvamount'],
            'ampAttack': ['attack'],
            'ampRelease': ['release']},
        'ZBP_SYNTH_00009': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterAttack': ['fil_attack'],
            'filterRelease': ['fil_release'],
            'filterType' : [],
            'ampAttack': ['amp_attack'],
            'ampRelease': ['amp_release']},
        'ZBP_SYNTH_00011': {
            'cutoff': ["filter cutoff"],
            'resonance': ['filter resonance'],
            'filterAttack': [],
            'filterRelease': [],
            'filterType' : [],
            'ampAttack': [],
            'ampRelease': []},
        'ZBP_SYNTH_00003': {
            'cutoff': ["flt_hp_cutoff_upper", "flt_hp_cutoff_lower"],
            'resonance': [],
            'filterAttack': [],
            'filterRelease': [],
            'filterType' : [],
            'ampAttack': [],
            'ampRelease': []},
        'ZBP_SYNTH_00006': {
            'cutoff': ["DCF1_CUTOFF"],
            'resonance': ['DCF1_RESO'],
            'filterAttack': ['DCF1_ATTACK'],
            'filterRelease': ['DCF1_RELEASE'],
            'filterType' : ['DCF1_TYPE'],
            'ampAttack': ['DCA1_ATTACK'],
            'ampRelease': ['DCA1_RELEASE']},
        'ZBP_SYNTH_00001': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterType' : [],
            'filterAttack' : []},
        'ZBP_SYNTH_00004': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterAttack' : ['filterattack'],
            'filterRelease': ['filterrelease'],
            'filterType' : ['filtertype'],
            'ampAttack': ['ampattack'],
            'ampRelease': ['amprelease']},
        'ZBP_SYNTH_00002': {
            'cutoff': ["filter_cutoff"],
            'resonance': ['filter_resonance'],
            'filterAttack' : ['filter_attack'],
            'filterRelease': ['filter_release'],
            'filterType' : [],
            'ampAttack': ['attack'],
            'ampRelease': ['release']},
        'ZBP_SYNTH_00013': {
            'cutoff': ["a_filter1_cutoff","a_filter2_cutoff","b_filter1_cutoff","b_filter2_cutoff"],
            'resonance': ['a_filter1_resonance', 'a_filter2_resonance','b_filter1_resonance','b_filter2_resonance'],
            'filterType' : ['a_filter1_type', 'a_filter2_type', 'b_filter1_type', 'b_filter2_type'],
            'filterAttack' : ['a_env1_attack', 'a_env2_attack'],
            'filterRelease' : ['a_env1_release', 'a_env2_release']},
        'ZBP_SYNTH_00000': {
            'cutoff': ["cutoff"],
            'resonance': ['res'],
            'filterAttack' : [],
            'filterRelease' : [],
            'filterType' : ['filter'],
            'ampAttack': ['adsr_a', 'adsr2_a'],
            'ampRelease': ['adsr_r', 'adsr2_r']}
    }

    contentItem: QQC2.Control {
        enabled: root.currentEngineId != null
        padding: 10

        background: Item {
            PlasmaCore.FrameSvgItem {
                id: svgBg4
                anchors.fill: parent

                readonly property real leftPadding: fixedMargins.left
                readonly property real rightPadding: fixedMargins.right
                readonly property real topPadding: fixedMargins.top
                readonly property real bottomPadding: fixedMargins.bottom

                imagePath: "widgets/tracks-background"
                colorGroup: PlasmaCore.Theme.ViewColorGroup
            }
        }

        contentItem: Loader {
            id: _loader
            // asynchronous: true
            sourceComponent: Item {

                ColumnLayout {
                    anchors.fill: parent
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Label {
                            text: "Simplified"
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
                            Text {
                                id: _test
                                text: root.objectName
                            }
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

                    Item {

                        Layout.fillWidth: true
                        Layout.fillHeight: true                        

                        QQC2.Control {
                            id: _padControl
                            width: 300
                            height: width
                            anchors.centerIn : parent

                            property bool lockValues : false

                            background: Rectangle {
                                border.color: "magenta"
                                color : "yellow"
                                opacity: 0.5
                                radius: 60
                            }

                            contentItem : Item {
                                id: _area

                                QQC2.Button {
                                    text: "Lock"
                                    checked: _padControl.lockValues
                                    onClicked: _padControl.lockValues = !_padControl.lockValues
                                }


                                Rectangle {
                                    id: _dot
                                    color: "red"
                                    width: 20
                                    height: 20
                                    radius: 10
                                    x: _drag.active ? Math.min(_area.width, Math.max(0, _drag.centroid.position.x)) : _area.cp
                                    y: _drag.active ? Math.min(_area.height, Math.max(0, _drag.centroid.position.y)) : _area.rp
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
                                    target: null
                                    xAxis.maximum: _area.width
                                    xAxis.minimum: 0
                                    yAxis.maximum: _area.height
                                    yAxis.minimum: 0

                                    readonly property real xPos : _drag.centroid.position.x
                                    readonly property real yPos : _drag.centroid.position.y

                                    onXPosChanged: _area.updateValues()
                                    onYPosChanged: _area.updateValues()

                                    onActiveChanged: {
                                        if(!active){
                                             if(_padControl.lockValues){
                                                _area.l_cp = _multiCutoffController.value
                                                _area.l_rp = _multiResController.value
                                            }else {
                                                _multiCutoffController.setValue(_area.l_cp)
                                                _multiResController.setValue(_area.l_rp)
                                            }
                                        }
                                    }
                                }

                                function updateValues(){

                                    if(_drag.active){
                                        _multiCutoffController.setValue((_drag.xPos/_area.width)*_multiCutoffController.to)
                                        _multiResController.setValue((_drag.yPos/_area.height)*_multiResController.to)
                                    }

                                    
                                }

                                property int l_cp : _multiCutoffController.value_default
                                property int l_rp : _multiResController.value_default

                                property int cp : Math.round(((_multiCutoffController.value)/_multiCutoffController.to) * _area.width) 
                                property int rp : Math.round(((_multiResController.value)/_multiResController.to) * _area.width) 

                                property int xp : Math.round((_dot.x * 100)/ _area.width)
                                property int yp: Math.round((_dot.y * 100)/ _area.height)

                                Text {
                                    color: "white"
                                    anchors.centerIn: parent
                                    text: _area.xp + " / " + _area.yp + " //\n " + _multiCutoffController.value + " =  " + _multiCutoffController.from + "/" + _multiCutoffController.to +"\n"+ _multiResController.value + " =  " + _multiResController.from + "/" + _multiResController.to 
                                }

                                QQC2.Label  {
                                    text: "Cutoff"
                                    anchors.bottom:  parent.bottom
                                    anchors.horizontalCenter:  parent.horizontalCenter
                                    opacity : 0.8
                                    anchors.margins: Kirigami.Units.smallSpacing  +6 
                                }


                                Item {   
                                    id: _parentLabel                    
                                    width: Kirigami.Units.gridUnit
                                    height: _label.implicitWidth

                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    anchors.margins: Kirigami.Units.smallSpacing  +6 

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
                        }
                    }
                }

                function cuiaCallback(cuia) {
                    _test.text = "cuia"
                    switch (cuia) {
                    case "SELECT_UP":
                    case "SELECT_DOWN":
                        return true
                    case "NAVIGATE_LEFT":
                    case "NAVIGATE_RIGHT":
                        return true
                    case "KNOB0_UP":
                        return true
                    case "KNOB0_DOWN":
                        return true
                    case "KNOB1_UP":
                    case "KNOB1_DOWN":
                    case "KNOB2_UP":
                    case "KNOB2_DOWN":
                        return true
                    case "KNOB3_UP":
                        return true
                    case "KNOB3_DOWN":
                        return true
                    case "SWITCH_SELECT_SHORT":
                    case "SWITCH_SELECT_BOLD":
                        return true
                    default:
                        return false;
                    }
                }
            }
        }
    }
}


