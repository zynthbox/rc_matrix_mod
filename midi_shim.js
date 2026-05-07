/**
 * Native MIDI shim — injected at DocumentCreation (same pass as qwebchannel.js).
 *
 * Strategy:
 *  1. Immediately replace navigator.requestMIDIAccess with a stub that
 *     queues every call. This happens synchronously before any page script runs.
 *  2. Initialise QWebChannel. When the channel is ready, drain the queue and
 *     resolve every pending promise with a native MIDIAccess object backed by
 *     the C++ MidiBridge exposed as "midiBridge".
 */
(function () {

    // ---- Queue to hold calls that arrive before the channel is ready ----------
    var pendingResolvers = [];
    var midiAccess = null;   // cached once built

    // Replace the API immediately — synchronously, before any page JS runs.
    var immediateDescriptor = {
        configurable: true,
        writable: true,
        value: function requestMIDIAccess(/* options */) {
            if (midiAccess) {
                console.log('[MidiShim] requestMIDIAccess called — returning cached access');
                return Promise.resolve(midiAccess);
            }
            console.log('[MidiShim] requestMIDIAccess called — channel not ready yet, queuing');
            return new Promise(function (resolve, reject) {
                pendingResolvers.push({ resolve: resolve, reject: reject });
            });
        }
    };
    try {
        Object.defineProperty(navigator, 'requestMIDIAccess', immediateDescriptor);
        console.log('[MidiShim] navigator.requestMIDIAccess replaced with queuing stub');
    } catch (e) {
        navigator.requestMIDIAccess = immediateDescriptor.value;
        console.warn('[MidiShim] defineProperty failed, used direct assignment:', e);
    }

    // ---- Web MIDI API types ---------------------------------------------------

    class MIDIInput {
        constructor(id, name) {
            this.id = id; this.name = name;
            this.manufacturer = ''; this.type = 'input';
            this.version = '1.0'; this.state = 'connected'; this.connection = 'open';
            this.onmidimessage = null; this.onstatechange = null;
            this._listeners = [];
        }
        addEventListener(type, fn) {
            if (type === 'midimessage') this._listeners.push(fn);
        }
        removeEventListener(type, fn) {
            if (type === 'midimessage')
                this._listeners = this._listeners.filter(f => f !== fn);
        }
        open()  { return Promise.resolve(this); }
        close() { return Promise.resolve(this); }
    }

    class MIDIOutput {
        constructor(id, name) {
            this.id = id; this.name = name;
            this.manufacturer = ''; this.type = 'output';
            this.version = '1.0'; this.state = 'connected'; this.connection = 'open';
            this.onstatechange = null; this._bridge = null;
        }
        send(data)  { this._bridge.sendMidi(this.id, Array.from(data)); }
        clear()     {}
        open()      { return Promise.resolve(this); }
        close()     { return Promise.resolve(this); }
    }

    // ---- Build MIDIAccess from port lists ------------------------------------

    function buildAccess(bridge, inputPorts, outputPorts) {
        var openInputs  = {};
        var inputMap    = new Map();
        var outputMap   = new Map();

        inputPorts.forEach(function (p) {
            var port = new MIDIInput(p.id, p.name);
            openInputs[p.id] = port;
            bridge.openInput(p.index, p.id);
            inputMap.set(p.id, port);
        });

        outputPorts.forEach(function (p) {
            var port = new MIDIOutput(p.id, p.name);
            port._bridge = bridge;
            bridge.openOutput(p.index, p.id);
            outputMap.set(p.id, port);
        });

        // Forward incoming MIDI bytes to the matching MIDIInput.
        bridge.midiMessageReceived.connect(function (portId, data) {
            var port = openInputs[portId];
            if (!port) return;
            var event = {
                data: new Uint8Array(data),
                target: port,
                timeStamp: performance.now()
            };
            if (typeof port.onmidimessage === 'function') port.onmidimessage(event);
            port._listeners.forEach(function (fn) { fn(event); });
        });

        return {
            inputs: inputMap, outputs: outputMap,
            sysexEnabled: true, onstatechange: null,
            addEventListener: function () {}, removeEventListener: function () {}
        };
    }

    // ---- Connect to QWebChannel and drain the queue --------------------------

    function initChannel() {
        if (typeof QWebChannel === 'undefined') {
            console.warn('[MidiShim] QWebChannel not yet defined, retrying in 50 ms');
            setTimeout(initChannel, 50);
            return;
        }
        if (!qt || !qt.webChannelTransport) {
            console.warn('[MidiShim] qt.webChannelTransport not ready, retrying in 50 ms');
            setTimeout(initChannel, 50);
            return;
        }

        console.log('[MidiShim] Opening QWebChannel transport...');
        new QWebChannel(qt.webChannelTransport, function (channel) {
            console.log('[MidiShim] QWebChannel connected. Objects:', Object.keys(channel.objects).join(', '));

            var bridge = channel.objects.nativeMidiBridge;
            if (!bridge) {
                console.error('[MidiShim] nativeMidiBridge not found on WebChannel — check registeredObjects in WebView.qml');
                pendingResolvers.forEach(function (p) {
                    p.reject(new DOMException('midiBridge not registered', 'InvalidStateError'));
                });
                pendingResolvers = [];
                return;
            }
            console.log('[MidiShim] midiBridge found, enumerating MIDI ports...');

            bridge.inputPorts(function (inputPorts) {
                console.log('[MidiShim] Input ports (' + inputPorts.length + '):', JSON.stringify(inputPorts));
                bridge.outputPorts(function (outputPorts) {
                    console.log('[MidiShim] Output ports (' + outputPorts.length + '):', JSON.stringify(outputPorts));

                    midiAccess = buildAccess(bridge, inputPorts, outputPorts);

                    // Upgrade stub to the real, no-wait implementation.
                    var finalDescriptor = {
                        configurable: true, writable: true,
                        value: function () {
                            console.log('[MidiShim] requestMIDIAccess called — returning native access');
                            return Promise.resolve(midiAccess);
                        }
                    };
                    try {
                        Object.defineProperty(navigator, 'requestMIDIAccess', finalDescriptor);
                    } catch (e) {
                        navigator.requestMIDIAccess = finalDescriptor.value;
                    }

                    // Drain any calls that arrived while the channel was connecting.
                    var queued = pendingResolvers.length;
                    pendingResolvers.forEach(function (p) { p.resolve(midiAccess); });
                    pendingResolvers = [];

                    console.log('[MidiShim] ✔ Native MIDI bridge active —',
                        inputPorts.length, 'inputs,', outputPorts.length, 'outputs.',
                        queued, 'queued call(s) drained.');
                });
            });
        });
    }

    console.log('[MidiShim] Script loaded at DocumentCreation — installing stub and opening channel');
    initChannel();

})();
