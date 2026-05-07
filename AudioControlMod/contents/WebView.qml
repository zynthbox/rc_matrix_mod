import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtWebEngine 1.10
import "helpers.js" as Helpers

Item {
    id: root

    property alias url: _webView.url
    property alias loading: _webView.loading

    /**
     * Convenience: load a URL with optional query parameters.
     * Uses Helpers.buildQuery() to encode the params object.
     */
    function loadWithParams(baseUrl, params) {
        var query = Helpers.buildQuery(params || {});
        _webView.url = query.length > 0 ? (baseUrl + "?" + query) : baseUrl;
    }

    MidiChannelTransport {
        id: _midiTransport
        view: _webView
        onReady: console.log("[WebView] MIDI transport ready —", inputCount, "in /", outputCount, "out")
        onBridgeError: console.error("[WebView] MIDI transport error:", message)
    }

    WebEngineView {
        id: _webView

        anchors.fill: parent

        // Persistent profile: stores HSTS state and disk cache across sessions,
        // required by strict-transport-security and cache-control: must-revalidate.
        profile: WebEngineProfile {
            id: _profile
            offTheRecord: true
        }

        settings {
            javascriptEnabled: true
            localContentCanAccessRemoteUrls: true
            localContentCanAccessFileUrls: true
            allowRunningInsecureContent: true
            errorPageEnabled: false
        }

        // Grant as early as possible — when the URL is set, before loading starts.
        onUrlChanged: _webView._grantMidi(_webView.url.toString())

        // Grant again at every loading stage to cover all timing windows.
        onLoadingChanged: function(loadRequest) {
            _webView._grantMidi(_webView.url.toString());
        }

        // Grant in response to explicit browser permission requests.
        onFeaturePermissionRequested: function(securityOrigin, feature) {
            Qt.callLater(function() {
                grantFeaturePermission(securityOrigin, feature, true);
            });
        }

        function _grantMidi(fullUrl) {
            var m = fullUrl.match(/^(https?:\/\/[^\/]+)/);
            var origin = m ? m[1] : fullUrl;
            Qt.callLater(function() {
                grantFeaturePermission(origin, WebEngineView.Midi, true);
                grantFeaturePermission(origin, WebEngineView.MidiSysex, true);
            });
        }

        webChannel: _midiTransport.channel

        // Accept self-signed / untrusted certificates (e.g. localhost dev servers)
        onCertificateError: function(error) {
            error.ignoreCertificateError();
        }

        // Enforce HSTS: redirect any http:// navigation to https://
        onNavigationRequested: function(request) {
            if (request.url.toString().startsWith("http://")) {
                request.action = WebEngineNavigationRequest.IgnoreRequest;
                _webView.url = request.url.toString().replace("http://", "https://");
            }
        }
    }

    QQC2.BusyIndicator {
        anchors.centerIn: parent
        running: _webView.loading
        visible: running
    }

}
