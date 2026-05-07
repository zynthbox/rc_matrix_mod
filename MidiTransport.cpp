#include "MidiTransport.h"
#include <QDebug>
#include <QMetaObject>
#include <QVariantMap>
#include <RtMidi.h>

MidiTransport::MidiTransport(QObject *parent) : QObject(parent) {}

MidiTransport::~MidiTransport()
{
    for (auto *p : _ins)    delete p;
    for (auto *p : _outs)   delete p;
    qDeleteAll(_cbData);
}

static QVariantList probePortList(bool input)
{
    QVariantList list;
    try {
        RtMidiIn  probeIn;
        RtMidiOut probeOut;
        unsigned int count = input ? probeIn.getPortCount() : probeOut.getPortCount();
        for (unsigned int i = 0; i < count; ++i) {
            QString name = QString::fromStdString(
                input ? probeIn.getPortName(i) : probeOut.getPortName(i));
            QVariantMap m;
            m[QStringLiteral("index")] = static_cast<int>(i);
            m[QStringLiteral("id")]    = (input ? QStringLiteral("in_") : QStringLiteral("out_")) + QString::number(i);
            m[QStringLiteral("name")]  = name;
            list.append(m);
        }
    } catch (const RtMidiError &e) {
        qWarning() << "[MidiTransport] probe error:" << e.getMessage().c_str();
    }
    return list;
}

QVariantList MidiTransport::inputPorts()  const { return probePortList(true);  }
QVariantList MidiTransport::outputPorts() const { return probePortList(false); }

bool MidiTransport::openInput(int portIndex, const QString &id)
{
    if (_ins.contains(id)) return true;
    try {
        auto *midi = new RtMidiIn();
        midi->ignoreTypes(false, false, false);
        auto *cb = new CbData{this, id};
        _cbData.append(cb);
        midi->setCallback(&MidiTransport::rtCallback, cb);
        midi->openPort(static_cast<unsigned int>(portIndex), id.toStdString());
        _ins.insert(id, midi);
        qDebug() << "[MidiTransport] input opened:" << id;
        return true;
    } catch (const RtMidiError &e) {
        qWarning() << "[MidiTransport] openInput failed:" << e.getMessage().c_str();
        return false;
    }
}

bool MidiTransport::openOutput(int portIndex, const QString &id)
{
    if (_outs.contains(id)) return true;
    try {
        auto *midi = new RtMidiOut();
        midi->openPort(static_cast<unsigned int>(portIndex), id.toStdString());
        _outs.insert(id, midi);
        qDebug() << "[MidiTransport] output opened:" << id;
        return true;
    } catch (const RtMidiError &e) {
        qWarning() << "[MidiTransport] openOutput failed:" << e.getMessage().c_str();
        return false;
    }
}

void MidiTransport::closeInput(const QString &id)
{
    if (auto *p = _ins.take(id)) delete p;
}

void MidiTransport::closeOutput(const QString &id)
{
    if (auto *p = _outs.take(id)) delete p;
}

void MidiTransport::send(const QString &portId, const QVariantList &bytes)
{
    auto it = _outs.find(portId);
    if (it == _outs.end()) { qWarning() << "[MidiTransport] send: unknown port" << portId; return; }
    std::vector<unsigned char> msg;
    msg.reserve(static_cast<size_t>(bytes.size()));
    for (const QVariant &b : bytes) msg.push_back(static_cast<unsigned char>(b.toInt()));
    try {
        it.value()->sendMessage(&msg);
    } catch (const RtMidiError &e) {
        qWarning() << "[MidiTransport] send failed:" << e.getMessage().c_str();
    }
}

void MidiTransport::rtCallback(double, std::vector<unsigned char> *msg, void *userData)
{
    auto *cb = static_cast<CbData *>(userData);
    QVariantList bytes;
    bytes.reserve(static_cast<int>(msg->size()));
    for (unsigned char b : *msg) bytes.append(static_cast<int>(b));
    QMetaObject::invokeMethod(cb->self, "received", Qt::QueuedConnection,
                              Q_ARG(QString, cb->id), Q_ARG(QVariantList, bytes));
}
