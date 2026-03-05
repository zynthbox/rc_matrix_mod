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

QQC2.Slider {
    id: slider
    implicitWidth: horizontal ? 300 : 28
    implicitHeight: horizontal ? 28 : 300

    property color highlightColor : "#5765f2"
    property color backgroundColor: "#333"
    property color foregroundColor: "#fafafa"
    property color alternativeColor :"#16171C"

    // property color highlightColor : Kirigami.Theme.highlightColor /*"#5765f2"*/
    // property color backgroundColor: Kirigami.Theme.backgroundColor /*"#333"*/
    // property color foregroundColor: Kirigami.Theme.textColor/*"#fafafa"*/
    // property color alternativeColor : Kirigami.Theme.alternateBackgroundColor /* "#16171C"*/

    orientation: Qt.Vertical

    padding: 4
    clip: false

    QQC2.Slider {
        id: _dummySlider
        height: parent.height
        width: parent.width
        x: (slider.width+16)
        value: slider.value
        onValueChanged: {
            slider.value = value
            slider.moved()
        }

        from: slider.from
        to: slider.to
        stepSize: slider.stepSize
        orientation: _slider.orientation
        visible: slider.enabled

        background: Rectangle {
            color: "transparent"
        }

        handle: Item {
            x: _dummySlider.orientation === Qt.Horizontal ? _dummySlider.leftPadding + _dummySlider.visualPosition * (_dummySlider.availableWidth - width) :
                                                            _dummySlider.leftPadding + _dummySlider.availableWidth / 2 - width / 2

            y: _dummySlider.orientation === Qt.Horizontal ?  _dummySlider.topPadding + _dummySlider.availableHeight / 2 - height / 2 :
                                                            _dummySlider.visualPosition * (_dummySlider.availableHeight - height)

            implicitWidth: _dummySlider.orientation === Qt.Horizontal ? 36 : 180
            implicitHeight: _dummySlider.orientation === Qt.Horizontal  ? _bgBox.height:  36

            Rectangle {

                width: _bgBox.width+16
                height: 36
                anchors.centerIn: parent
                radius: 6
                color: slider.backgroundColor
                border.color: Qt.darker(slider.alternativeColor, 2)

                layer.enabled: !_dummySlider.pressed
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 8.0
                    samples: 17
                    color: "#80000000"
                }

                Rectangle {
                    color: "transparent"
                    border.color: Qt.lighter(slider.alternativeColor, 2)
                    border.width :2
                    radius: parent.radius
                    anchors.fill: parent
                    anchors.margins: 1
                }

                Rectangle {
                    height: 6
                    width: _verticalRec.width
                    radius: 5
                    anchors.centerIn: parent

                    color: slider.highlightColor
                }
            }
        }
    }

    handle: Item {
        visible: false
        x: slider.orientation === Qt.Horizontal ? slider.leftPadding + slider.visualPosition * (slider.availableWidth - width) :
                                                  slider.leftPadding + slider.availableWidth / 2 - width / 2

        y: slider.orientation === Qt.Horizontal ?  slider.topPadding + slider.availableHeight / 2 - height / 2 :
                                                  slider.visualPosition * (slider.availableHeight - height)

        implicitWidth: slider.orientation === Qt.Horizontal ? 36 : 180
        implicitHeight: slider.orientation === Qt.Horizontal  ? _bgBox.height:  36

        Rectangle {
            width: _bgBox.width+16
            height: 36
            anchors.centerIn: parent
            radius: 6
            color: slider.backgroundColor
            border.color: Qt.darker(slider.alternativeColor, 2)

            layer.enabled: !slider.pressed
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: 8.0
                samples: 17
                color: "#80000000"
            }

            Rectangle {
                color: "transparent"
                border.color: Qt.lighter(slider.alternativeColor, 2)
                border.width :2
                radius: parent.radius
                anchors.fill: parent
                anchors.margins: 1
            }

            Rectangle {
                height: 6
                width: _verticalRec.width
                radius: 5
                anchors.centerIn: parent

                color: slider.highlightColor
            }
        }

        QQC2.Label {
            height: 36
            width: 60
            anchors.verticalCenter: parent.verticalCenter
            visible: slider.pressed

            text: slider.position.toFixed(2)
            color: slider.foregroundColor
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.capitalization: Font.AllUppercase
            font.weight: Font.DemiBold
            font.family: "Hack"
            font.pointSize: 9
            padding: 10
            background: Rectangle {
                color: slider.backgroundColor
                border.color: Qt.darker(slider.alternativeColor, 2)
                radius: 6
                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 12.0
                    samples: 17
                    color:"#80000000"
                }

            }
        }
    }

    background: Rectangle {

        border.color: slider.pressed ? slider.highlightColor : slider.backgroundColor
        color: "transparent"
        radius: 6

        Rectangle {
            id: _bgBox
            visible: false
            anchors.fill: parent
            anchors.margins: 1
            color: slider.backgroundColor
            radius: parent.radius
            border.color: Qt.darker(color, 1.8)
        }

        InnerShadow {
              opacity: 0.5
            anchors.fill: _bgBox
            radius: 8.0
            samples: 16
            horizontalOffset: 1
            verticalOffset: 3
            color: "#b0000000"
            source: _bgBox
        }

        InnerShadow {
            anchors.fill: _bgBox
            opacity: 0.5
            radius: 8.0
            samples: 16
            horizontalOffset: -1
            verticalOffset: -3
            color: "#b0000000"
            source: _bgBox
        }

        Rectangle {
            visible: slider.orientation === Qt.Horizontal

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 5
            border.color: Qt.darker(color, 2)
            color: slider.alternativeColor
            height: 8
            radius: 5

            Rectangle {
                height: parent.height
                width: slider.position * parent.width
                color: slider.highlightColor
                radius: parent.radius
                border.color: parent.border.color
                RadialGradient {
                    anchors.fill: parent
                    opacity: 0.7
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.lighter(slider.highlightColor, 2) }
                        GradientStop { position: 0.5; color: "transparent" }
                    }
                }
            }


        }

        Item {
            id: _verticalRec
            visible: slider.orientation === Qt.Vertical
            anchors.fill: parent
            anchors.margins: 5
            // border.color: Qt.darker(color, 2)
            // color: slider.alternativeColor
            width: parent.width
            // radius: 5

            Column{
                anchors.fill: parent
                topPadding: spacing/2
                spacing: 6

                Repeater {
                    id: _repeater
                    model: Math.round(_verticalRec.height/12)
                    Item {

                        width: parent.width
                        height: 6

                        Rectangle {
                            id: bulb
                            property bool highlighted : slider.position> position
                            property double position : 1 -((index * 1.07) / _repeater.count)

                            anchors.fill: parent
                            radius: 5
                            opacity:  highlighted ? 1.0 : 0.9
                            color:  highlighted ? slider.highlightColor : slider.alternativeColor
                            RadialGradient {
                                visible: bulb.highlighted
                                anchors.fill: parent
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: Qt.lighter(slider.highlightColor) }
                                    GradientStop { position: 0.5; color: "transparent" }
                                }
                            }
                        }
                    }
                }
            }
            // Rectangle {
            //     width: parent.width
            //     height: (slider.position * parent.height)
            //     anchors.bottom: parent.bottom
            //     color: slider.highlightColor
            //     radius: parent.radius
            //     border.color: parent.border.color
            //     RadialGradient {
            //         anchors.fill: parent
            //         opacity: 0.7
            //         gradient: Gradient {
            //             GradientStop { position: 0.0; color: Qt.lighter(slider.highlightColor, 2) }
            //             GradientStop { position: 0.5; color: "transparent" }
            //         }
            //     }
            // }
        }
    }
}


