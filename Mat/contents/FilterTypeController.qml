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

import QtQuick 2.10
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.2 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import io.zynthbox.ui 1.0 as Zynthian
import "." as Here
import QtGraphicalEffects 1.15

QQC2.Control {

    id: root
    enabled: controllersIds.length > 0
    opacity: enabled ? 1 : 0.5
    property var controllersIds : []
    default property alias content : _container.data

    property double value : 0.0
    property double from: 0.0
    property double to : 0.0
    property int stepSize : 1
    property string printValue

    property color highlightColor : Kirigami.Theme.highlightColor /*"#5765f2"*/
    property color backgroundColor: Kirigami.Theme.backgroundColor /*"#333"*/
    property color foregroundColor: Kirigami.Theme.textColor/*"#fafafa"*/
    property color alternativeColor : Kirigami.Theme.alternateBackgroundColor /* "#16171C"*/

    property bool highlighted : false

    property alias title : _label1.text
    readonly property string displayText : printValue
    property bool debugMode: false
    property int pendingParamIndexUpdate: 0
    property Item knobControl : null

    Repeater {
        id: watcher
        model: root.controllersIds
        // onCountChanged: calculate()

        delegate: Item {
            id:  controlRoot
            objectName: "Controller#"+symbol
            property string symbol : modelData

            Zynthian.ControllerGroup {
                id: controller
                symbol: controlRoot.symbol
            }

            readonly property var value : controller != null && controller.ctrl != null ? controller.ctrl.value : 0
            readonly property QtObject ctrl : controller.ctrl
            readonly property int mindex : index

            onCtrlChanged: {
                if (controller != null && controller.ctrl != null) {
                    if(watcher.count<=0)
                        return

                    var item =  watcher.itemAt(controlRoot.mindex)
                    if (item != null && item.ctrl != null) {
                        var fromValue = item.ctrl.value0
                        var toValue = item.ctrl.max_value

                        root.from = fromValue
                        root.to = toValue
                        root.stepSize = item.ctrl ? (item.ctrl.step_size === 0 ? 1 : item.ctrl.step_size) : 0

                        calculate(mindex)
                    }
                }
            }

            onValueChanged: {
                if(root.visible)
                    calculate(mindex)
                else
                    root.pendingParamIndexUpdate = mindex
            }
        }
    }

    background: Item {

        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            color: "transparent"
            border.color: "white"
            border.width: 2
            visible: root.activeFocus
        }
    }

    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent

            QQC2.Label {
                id: _label1
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.capitalization: Font.AllUppercase
                font.weight: Font.DemiBold
                font.family: "Hack"
                font.pointSize: 9
                color: root.foregroundColor
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    id: _container
                    anchors.fill: parent
                }
            }

            QQC2.Label {
                visible: enabled
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.displayText
                font.capitalization: Font.AllUppercase
                font.weight: Font.DemiBold
                font.family: "Hack"
                font.pointSize: 9
                fontSizeMode: Text.Fit
                minimumPointSize: 6
                wrapMode: Text.NoWrap

                font.letterSpacing: 2
                color: root.foregroundColor
                padding: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.debugMode = !root.debugMode
                }

                background: Rectangle {

                    border.width: 2
                    border.color: root.backgroundColor
                    color: root.alternativeColor
                    radius: 4

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1

                        visible: false
                        id: _recLabel
                        color: root.highlighted ? root.highlightColor : root.alternativeColor
                        border.color: Qt.darker(color, 2)
                        radius: 4

                    }

                    InnerShadow {
                        anchors.fill: _recLabel
                        opacity: 0.5
                        radius: 8.0
                        samples: 16
                        horizontalOffset: -3
                        verticalOffset: 1
                        color: "#b0000000"
                        source: _recLabel
                    }

                    InnerShadow {
                        anchors.fill: _recLabel
                        opacity: 0.5
                        radius: 8.0
                        samples: 16
                        horizontalOffset: 3
                        verticalOffset: -1
                        color: "#b0000000"
                        source: _recLabel
                    }
                }
            }

            Loader {
                active: visible
                visible: enabled && root.debugMode
                asynchronous: true

                Layout.fillWidth: true
                sourceComponent: QQC2.Control {

                    padding: 4
                    contentItem: Column {
                        Repeater {
                            model: watcher.count

                            delegate: Text {

                                property Item obj : watcher.itemAt(modelData)
                                width: parent.width
                                color: root.foregroundColor
                                text:  obj != null && obj.ctrl != null ? "%1 : %2 | %3".arg(obj.ctrl.title).arg(obj.ctrl.value.toFixed(2)).arg(obj.ctrl.value_print) : ""
                                font.pointSize: 6
                                fontSizeMode: Text.Fit
                                minimumPointSize: 4
                                wrapMode: Text.NoWrap
                            }
                        }
                    }

                    background: Rectangle {

                        border.width: 2
                        border.color: root.alternativeColor
                        color: root.backgroundColor
                        radius: 4

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1

                            visible: false
                            id: _infoRec
                            color: root.alternativeColor
                            border.color: Qt.darker(color, 2)
                            radius: 4

                        }

                        InnerShadow {
                            anchors.fill: _infoRec
                            radius: 8.0
                            samples: 16
                            horizontalOffset: -3
                            verticalOffset: 1
                            color: "#b0000000"
                            source: _infoRec
                        }
                    }
                }
            }

        }
    }

    onVisibleChanged: {
        if(visible)
        {
            calculate(root.pendingParamIndexUpdate)
            var value = root.value
            setValue(value)
        }
    }

    function calculate(index = 0) {

        if(watcher.count<=0)
            return

        var item = watcher.itemAt(index)
        root.value = item.ctrl.value
        root.printValue = item.ctrl.value_print
    }

    function setValue(value) {
        // if(value === root.value)
        //     return

        // var percent = value / root.to
        var i = 0
        for (i; i < watcher.count; i++) {
            watcher.itemAt(i).ctrl.value = value
        }

        calculate()
    }

    function increaseValue() {
        setValue(root.value+stepSize)
    }

    function decreaseValue() {
          setValue(root.value-stepSize)
    }
}
