#!/usr/bin/env python3
"""
Standalone test runner for AudioControlMod/contents/main.qml.
Stubs out the Zynthbox/KDE/Plasma context objects that the QML expects.
"""

import os
import sys

os.environ["QTWEBENGINE_CHROMIUM_FLAGS"] = (
    "--no-sandbox --disable-web-security --allow-running-insecure-content"
)

from PySide2.QtWebEngine import QtWebEngine
from PySide2.QtCore import QObject, Property, Signal, QUrl
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine, qmlRegisterType


# ---------------------------------------------------------------------------
# Minimal stubs so the QML bindings don't crash on missing context properties
# ---------------------------------------------------------------------------

class SketchpadStub(QObject):
    isMetronomeRunningChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._running = False

    @Property(bool, notify=isMetronomeRunningChanged)
    def isMetronomeRunning(self):
        return self._running


class ControlStub(QObject):
    all_controlsChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)


class ZynqtguiStub(QObject):
    curlayerEngineIdChanged = Signal()
    curlayerEngineNameChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._sketchpad = SketchpadStub(self)
        self._control = ControlStub(self)

    @Property(str, notify=curlayerEngineIdChanged)
    def curlayerEngineId(self):
        return ""

    @Property(str, notify=curlayerEngineNameChanged)
    def curlayerEngineName(self):
        return "Test Engine"

    @Property(QObject, constant=True)
    def sketchpad(self):
        return self._sketchpad

    @Property(QObject, constant=True)
    def control(self):
        return self._control


# ---------------------------------------------------------------------------

def main():
    QtWebEngine.initialize()

    app = QGuiApplication(sys.argv)
    app.setOrganizationName("audiocontrol_mod")
    app.setApplicationName("AudioControlMod")

    engine = QQmlApplicationEngine()

    # Expose stub so QML references to `zynqtgui` resolve
    zynqtgui = ZynqtguiStub()
    engine.rootContext().setContextProperty("zynqtgui", zynqtgui)

    # Stub for applicationWindow() used in the QML
    engine.rootContext().setContextProperty("selectedChannel", None)

    qml_file = os.path.join(os.path.dirname(__file__),
                            "AudioControlMod", "contents", "main.qml")
    engine.load(QUrl.fromLocalFile(qml_file))

    if not engine.rootObjects():
        print("ERROR: failed to load QML", file=sys.stderr)
        sys.exit(1)

    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
