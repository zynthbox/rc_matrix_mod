#include "MidiBridge.h"
#include <QDebug>
#include <QMetaObject>
#include <QVariantMap>
#include <RtMidi.h>

MidiBridge::MidiBridge(QObject *parent) : QObject(parent) {}

MidiBridge::~MidiBridge()
{
    for (auto *p : _inputs)      delete p;
    for (auto *p : _outputs)     delete p;
    qDeleteAll(_callbackData);
}

QVariantList MidiBridge::inputPorts() const
{
    QVariantList ports;
    try {
        RtMidiIn probe;
        unsigned int count = probe.getPortCount();
        for (unsigned int i = 0; i < count; ++i) {
            QVariantMap p;
            p[QStringLiteral("index")] = static_cast<int>(i);
            p[QStringLiteral("id")]    = QStringLiteral("in_%1").arg(i);
            p[QStringLiteral("name")]  = QString::fromStdString(probe.getPortName(i));
            ports.append(p);
        }
    } catch (const RtMidiError &e) {
        qWarning() << "MidiBridge::inputPorts:" << e.getMessage().c_str();
    }
    return ports;
}

QVariantList MidiBridge::outputPorts() const
{
    QVariantList ports;
    try {
        RtMidiOut probe;
        unsigned int count = probe.getPortCount();
        for (unsigned int i = 0; i < count; ++i) {
            QVariantMap p;
            p[QStringLiteral("index")] = static_cast<int>(i);
            p[QStringLiteral("id")]    = QStringLiteral("out_%1").arg(i);
            p[QStringLiteral("name")]  = QString::fromStdString(probe.getPortName(i));
            ports.append(p);
        }
    } catch (const RtMidiError &e) {
        qWarning() << "MidiBridge::outputPorts:" << e.getMessage().c_str();
    }
    return ports;
}

bool MidiBridge::openInput(int portIndex, const QString &portId)
{
    if (_inputs.contains(portId)) return true;
    try {
        auto *midi = new RtMidiIn();
        midi->ignoreTypes(false, false, false); // receive sysex, timing, active sensing
        auto *cb = new CallbackData{this, portId};
        _callbackData.append(cb);
        midi->setCallback(&MidiBridge::rtMidiCallback, cb);
        midi->openPort(static_cast<unsigned int>(portIndex), portId.toStdString());
        _inputs.insert(portId, midi);
        qDebug() << "MidiBridge: opened input" << portId;
        return true;
    } catch (const RtMidiError &e) {
        qWarning() << "MidiBridge::openInput failed:" << e.getMessage().c_str();
        return false;
    }
}

bool MidiBridge::openOutput(int portIndex, const QString &portId)
{
    if (_outputs.contains(portId)) return true;
    try {
        auto *midi = new RtMidiOut();
        midi->openPort(static_cast<unsigned int>(portIndex), portId.toStdString());
        _outputs.insert(portId, midi);
        qDebug() << "MidiBridge: opened output" << portId;
        return true;
    } catch (const RtMidiError &e) {
        qWarning() << "MidiBridge::openOutput failed:" << e.getMessage().c_str();
        return false;
    }
}

void MidiBridge::closeInput(const QString &portId)
{
    if (auto *midi = _inputs.take(portId)) delete midi;
}

void MidiBridge::closeOutput(const QString &portId)
{
    if (auto *midi = _outputs.take(portId)) delete midi;
}

void MidiBridge::sendMidi(const QString &portId, const QVariantList &data)
{
    auto it = _outputs.find(portId);
    if (it == _outputs.end()) {
        qWarning() << "MidiBridge::sendMidi: unknown port" << portId;
        return;
    }
    std::vector<unsigned char> msg;
    msg.reserve(static_cast<size_t>(data.size()));
    for (const QVariant &b : data)
        msg.push_back(static_cast<unsigned char>(b.toInt()));
    try {
        it.value()->sendMessage(&msg);
    } catch (const RtMidiError &e) {
        qWarning() << "MidiBridge::sendMidi failed:" << e.getMessage().c_str();
    }
}

void MidiBridge::rtMidiCallback(double /*timestamp*/,
                                std::vector<unsigned char> *message,
                                void *userData)
{
    auto *cb = static_cast<CallbackData *>(userData);
    QVariantList data;
    data.reserve(static_cast<int>(message->size()));
    for (unsigned char byte : *message)
        data.append(static_cast<int>(byte));
    // Callback fires on RtMidi's thread — queue the signal to the Qt thread.
    QMetaObject::invokeMethod(cb->bridge, "midiMessageReceived",
                              Qt::QueuedConnection,
                              Q_ARG(QString,      cb->portId),
                              Q_ARG(QVariantList, data));
}
