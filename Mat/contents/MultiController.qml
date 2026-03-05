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
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.2 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import io.zynthbox.ui 1.0 as Zynthian
import "." as Here

Item {

    id: root
    enabled: controllersIds.length > 0
    property var controllersIds : []

    property double value : 0.0
    property double from: 0.0
    property double to : 0.0
    property double stepSize: 1

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

            readonly property var value : controller.ctrl != null ? controller.ctrl.value : 0
            readonly property QtObject ctrl : controller.ctrl

            onCtrlChanged: {
                if (controller.ctrl != null) {
                    var fromValue = 0.0
                    var toValue = 0.0

                    var i = 0
                    for (i; i < watcher.count; i++) {
                        var item = watcher.itemAt(i)
                        if (item != null && item.ctrl != null) {
                            fromValue += item.ctrl.value0
                            toValue += item.ctrl.max_value
                        } else {
                            break;
                        }
                    }

                    root.from = fromValue/i
                    root.to = toValue/i
                    root.stepSize = ctrl.step_size === 0 ? 1 : ctrl.step_size

                    calculate()
                }
            }

            onValueChanged: {
                if(root.visible)
                    calculate()
            }
        }
    }

    onVisibleChanged: {
        if(visible)
            calculate()
    }

    function calculate() {
        if(!root.visible)
            return;

        var sumValue = 0.0
        var i = 0
        for (i; i < watcher.count; i++) {
            var item = watcher.itemAt(i)
            if(item.ctrl)
                sumValue += item.ctrl.value
        }

        var mediumValue = sumValue / i
        root.value = mediumValue
        root.valueChanged()
    }

    function setValue(value) {
        if(value === root.value)
            return

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
