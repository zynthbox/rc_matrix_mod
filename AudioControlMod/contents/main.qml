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
import "helpers.js" as Helpers
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
    
    
    contentItem: Here.WebView {
        id: webview
        anchors.fill: parent
        url: "https://audiocontrol.org/roland/s330/editor"

        Text {
            color: "orange"
            text: root.width + "x" + root.height + " @ " + root.mapToItem(null, 0, 0).x + "," + root.mapToItem(null, 0, 0).y
        }
    }

}
