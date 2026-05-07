import QtQuick 2.15
import QtWebEngine 1.10
import QtWebChannel 1.0

/**
 * MidiChannelTransport
 *
 * Owns the WebChannel and injects the JZZ.js + QWebChannel engine scripts
 * that replace navigator.requestMIDIAccess with a native RtMidi-backed
 * JZZ.js implementation.
 *
 * Injection order (all DocumentCreation, MainWorld):
 *   1. qwebchannel.js      — sets up qt.webChannelTransport
 *   2. jzz.js              — JZZ core (node_modules/jzz/javascript/JZZ.js)
 *   3. jzz_webchannel.js   — registers the QWebChannel JZZ engine
 *
 * Usage:
 *   MidiChannelTransport { id: _transport; view: _webView }
 *   WebEngineView { webChannel: _transport.channel }
 */
QtObject {
    id: root

    property var view: null

    readonly property alias channel: _channel

    signal ready(int inputCount, int outputCount)
    signal bridgeError(string message)

    property WebChannel _channel: WebChannel { id: _channel }

    Component.onCompleted: {
        if (!view) {
            console.error("[MidiTransport] 'view' property not set");
            return;
        }

        // Register C++ MidiTransport imperatively to avoid segfault on
        // declarative binding before the context property is resolved.
        _channel.registerObject("midiTransport", midiTransport);
        console.log("[MidiTransport] midiTransport registered on WebChannel");

        _injectScripts();
    }

    function _injectScripts() {
        function load(url) {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", url, false);
            xhr.send();
            if (!xhr.responseText)
                console.error("[MidiTransport] Failed to load:", url);
            return xhr.responseText;
        }

        var qwcJs    = load("qrc:///qtwebchannel/qwebchannel.js");
        var jzzJs    = load("qrc:/AudioControlMod/jzz.js");
        var engineJs = load("qrc:/AudioControlMod/jzz_webchannel.js");

        if (!qwcJs || !engineJs) {
            root.bridgeError("Required scripts missing from resources");
            return;
        }
        if (!jzzJs)
            console.warn("[MidiTransport] jzz.js not found — copy node_modules/jzz/javascript/JZZ.js to jzz.js");

        function makeScript(name, src) {
            var s = Qt.createQmlObject('import QtWebEngine 1.10; WebEngineScript {}', view);
            s.name           = name;
            s.injectionPoint = WebEngineScript.DocumentCreation;
            s.worldId        = WebEngineScript.MainWorld;
            s.sourceCode     = src;
            return s;
        }

        var scripts = [ makeScript("qwebchannel", qwcJs) ];
        if (jzzJs) scripts.push(makeScript("jzz", jzzJs));
        scripts.push(makeScript("jzz_webchannel", engineJs));

        view.userScripts.collection = scripts;

        console.log("[MidiTransport] Injected", scripts.length, "scripts (DocumentCreation, MainWorld)");
    }
}
