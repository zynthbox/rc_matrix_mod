#pragma once
#include <QList>
#include <QMap>
#include <QObject>
#include <QVariantList>
#include <vector>

class RtMidiIn;
class RtMidiOut;

/**
 * MidiTransport
 *
 * Minimal RtMidi wrapper exposed via QWebChannel.
 * The JS side (jzz_webchannel.js) registers this as a JZZ.js engine,
 * routing all MIDI I/O through the channel.
 */
class MidiTransport : public QObject
{
    Q_OBJECT
public:
    explicit MidiTransport(QObject *parent = nullptr);
    ~MidiTransport() override;

    Q_INVOKABLE QVariantList inputPorts()  const;
    Q_INVOKABLE QVariantList outputPorts() const;

    Q_INVOKABLE bool openInput (int portIndex, const QString &id);
    Q_INVOKABLE bool openOutput(int portIndex, const QString &id);
    Q_INVOKABLE void closeInput (const QString &id);
    Q_INVOKABLE void closeOutput(const QString &id);

    Q_INVOKABLE void send(const QString &portId, const QVariantList &bytes);

signals:
    void received(const QString &portId, const QVariantList &bytes);

private:
    struct CbData { MidiTransport *self; QString id; };

    static void rtCallback(double, std::vector<unsigned char> *, void *);

    QMap<QString, RtMidiIn  *> _ins;
    QMap<QString, RtMidiOut *> _outs;
    QList<CbData *>            _cbData;
};
