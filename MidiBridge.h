#pragma once
#include <QMap>
#include <QObject>
#include <QVariantList>
#include <memory>
#include <vector>

class RtMidiIn;
class RtMidiOut;

class MidiBridge : public QObject
{
    Q_OBJECT
public:
    explicit MidiBridge(QObject *parent = nullptr);
    ~MidiBridge() override;

    // Called from JS via QWebChannel — list available ports
    Q_INVOKABLE QVariantList inputPorts() const;
    Q_INVOKABLE QVariantList outputPorts() const;

    // Open/close ports by index (from the port list) and a caller-supplied id
    Q_INVOKABLE bool openInput(int portIndex, const QString &portId);
    Q_INVOKABLE bool openOutput(int portIndex, const QString &portId);
    Q_INVOKABLE void closeInput(const QString &portId);
    Q_INVOKABLE void closeOutput(const QString &portId);

    // Send raw MIDI bytes to an open output port
    Q_INVOKABLE void sendMidi(const QString &portId, const QVariantList &data);

signals:
    // Emitted (queued, safe from RtMidi callback thread) when a message arrives
    void midiMessageReceived(const QString &portId, const QVariantList &data);

private:
    struct CallbackData {
        MidiBridge *bridge;
        QString     portId;
    };

    static void rtMidiCallback(double timestamp,
                               std::vector<unsigned char> *message,
                               void *userData);

    QMap<QString, RtMidiIn *>    _inputs;
    QMap<QString, RtMidiOut *>   _outputs;
    QList<CallbackData *>        _callbackData;
};
