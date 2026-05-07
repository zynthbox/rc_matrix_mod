/**
 * jzz_webchannel.js
 *
 * Connects JZZ.js to a C++ RtMidi backend via QWebChannel.
 *
 * Injection order (DocumentCreation, MainWorld):
 *   1. qwebchannel.js      — sets up qt.webChannelTransport
 *   2. jzz.js              — JZZ core; installs JZZ.requestMIDIAccess on navigator
 *   3. jzz_webchannel.js   — this file
 *
 * Strategy:
 *   - JZZ.js runs first and installs JZZ.requestMIDIAccess as navigator.requestMIDIAccess.
 *     We save that reference, then replace it with a queuing stub.
 *   - We connect QWebChannel asynchronously and register a JZZ engine backed by
 *     C++ MidiTransport.
 *   - Once JZZ initialises with that engine, we restore JZZ.requestMIDIAccess on
 *     navigator, then drain any queued calls through it.
 */
(function () {
    'use strict';

    if (typeof JZZ === 'undefined') {
        console.error('[JZZ-WC] JZZ not loaded — ensure jzz.js is injected before this script');
        return;
    }

    // ── 1. Save JZZ's requestMIDIAccess and install queuing stub ─────────────
    // JZZ.js already placed its implementation on navigator. We hold pending
    // calls in a queue until our engine is ready, then replay through JZZ.
    var _jzzRequestMIDIAccess = JZZ.requestMIDIAccess;   // always available
    var _pending = [];

    function _stub(opt) {
        console.log('[JZZ-WC] requestMIDIAccess called — queuing until engine ready');
        return new Promise(function (res, rej) {
            _pending.push({ opt: opt, res: res, rej: rej });
        });
    }

    function _install(fn) {
        var desc = { configurable: true, writable: true, value: fn };
        try { Object.defineProperty(navigator, 'requestMIDIAccess', desc); }
        catch (e) { navigator.requestMIDIAccess = fn; }
    }

    _install(_stub);
    console.log('[JZZ-WC] Queuing stub installed, connecting WebChannel...');

    // ── 2. Connect QWebChannel ────────────────────────────────────────────────
    function _connect() {
        if (typeof QWebChannel === 'undefined' || !window.qt || !qt.webChannelTransport) {
            return setTimeout(_connect, 50);
        }
        console.log('[JZZ-WC] Opening WebChannel transport...');
        new QWebChannel(qt.webChannelTransport, function (channel) {
            console.log('[JZZ-WC] Channel connected. Objects:', Object.keys(channel.objects).join(', '));
            var transport = channel.objects.midiTransport;
            if (!transport) {
                console.error('[JZZ-WC] midiTransport not found on channel');
                _fail('midiTransport not registered');
                return;
            }
            _setupEngine(transport);
        });
    }

    // ── 3. Register and start the JZZ engine ─────────────────────────────────
    function _setupEngine(transport) {
        transport.inputPorts(function (ins) {
            transport.outputPorts(function (outs) {
                console.log('[JZZ-WC] Ports — in:', ins.length, 'out:', outs.length);

                var _inPorts = {};

                // Route RtMidi callbacks into JZZ input port listeners.
                transport.received.connect(function (portId, bytes) {
                    var p = _inPorts[portId];
                    if (p && p._emit) p._emit(new Uint8Array(bytes));
                });

                var engineInfo = {
                    sysex:   true,
                    inputs:  ins.map( function (p) { return { id: p.id, name: p.name, manufacturer: '' }; }),
                    outputs: outs.map(function (p) { return { id: p.id, name: p.name, manufacturer: '' }; })
                };

                JZZ.lib.registerPlugin('webchannel', function (plugin) {
                    plugin.init = function (done) {
                        ins.forEach(function (p) {
                            transport.openInput(p.index, p.id);
                            // Minimal event emitter that JZZ calls into for incoming data.
                            _inPorts[p.id] = (function () {
                                var fns = [];
                                return {
                                    _emit: function (data) { fns.forEach(function (fn) { fn(data); }); },
                                    on:  function (ev, fn) { if (ev === 'midi') fns.push(fn); },
                                    off: function (ev, fn) { if (ev === 'midi') fns = fns.filter(function (f) { return f !== fn; }); }
                                };
                            })();
                        });
                        outs.forEach(function (p) { transport.openOutput(p.index, p.id); });
                        done(null, engineInfo);
                    };

                    plugin.send = function (portId, bytes) {
                        transport.send(portId, Array.from(bytes));
                    };
                });

                JZZ({ engine: 'webchannel', sysex: true })
                    .or(function () {
                        console.error('[JZZ-WC] JZZ engine init failed:', this.err);
                        _fail('JZZ engine init failed: ' + this.err);
                    })
                    .and(function () {
                        console.log('[JZZ-WC] JZZ engine ready — restoring JZZ.requestMIDIAccess');

                        // Replace stub with the real JZZ implementation backed by our engine.
                        _install(_jzzRequestMIDIAccess);

                        // Drain queued calls through JZZ now that the engine is live.
                        var queued = _pending.splice(0);
                        queued.forEach(function (item) {
                            _jzzRequestMIDIAccess.call(navigator, item.opt || { sysex: true })
                                .then(item.res)
                                .catch(item.rej);
                        });

                        console.log('[JZZ-WC] ✔ Native MIDI bridge active —',
                            ins.length, 'in /', outs.length, 'out.',
                            queued.length, 'queued call(s) drained.');
                    });
            });
        });
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    function _fail(msg) {
        _install(_stub); // keep stub so calls don't hit native API
        var queued = _pending.splice(0);
        queued.forEach(function (item) {
            item.rej(new DOMException(msg, 'NotSupportedError'));
        });
    }

    _connect();

})();
