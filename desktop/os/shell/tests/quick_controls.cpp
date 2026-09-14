#include "QuickControlsBackend.h"
#include <QCoreApplication>
#include <QDir>
#include <QEventLoop>
#include <QFile>
#include <QTemporaryDir>
#include <QTimer>

static void require(bool condition, const char *message)
{
    if (!condition)
        qFatal("%s", message);
}
static void wait(int ms)
{
    QEventLoop loop;
    QTimer::singleShot(ms, &loop, &QEventLoop::quit);
    loop.exec();
}
static void command(const QString &directory, const QString &name, const QByteArray &body)
{
    QFile file(directory + "/" + name);
    require(file.open(QIODevice::WriteOnly), "Cannot create test helper");
    file.write("#!/bin/sh\n[ \"$LC_ALL\" = C ] || exit 10\n");
    file.write(body);
    file.close();
    require(file.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner |
                                QFileDevice::ExeOwner), "Cannot mark helper executable");
}
int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    QTemporaryDir directory;
    require(directory.isValid(), "Cannot create temporary directory");
    qputenv("PATH", directory.path().toUtf8());
    qputenv("LC_ALL", "es_EC.UTF-8");
    command(directory.path(), "nmcli", "echo enabled\n");
    command(directory.path(), "wpctl", "echo 'Volume: 0.42 [MUTED]'\n");
    command(directory.path(), "bluetoothctl", "echo 'No default controller available'\n");
    QuickControlsBackend controls;
    wait(500);
    require(controls.networkAvailable() && controls.wifiEnabled(), "Spanish locale broke Wi-Fi parsing");
    require(controls.audioAvailable() && controls.volume() == 42 && controls.muted(), "Audio parsing failed");
    require(!controls.bluetoothAvailable(), "Missing adapter reported as available");

    command(directory.path(), "nmcli", "exec /bin/sleep 10\n");
    command(directory.path(), "wpctl", "exit 1\n");
    command(directory.path(), "bluetoothctl", "echo 'Controller test'\necho 'Powered: yes'\n");
    int ticks = 0;
    QTimer heartbeat;
    QObject::connect(&heartbeat, &QTimer::timeout, [&] { ++ticks; });
    heartbeat.start(20);
    controls.refresh();
    controls.refresh(); // overlapping requests must be coalesced
    wait(2300);
    require(ticks > 50, "A system query blocked the GUI event loop");
    require(!controls.networkAvailable(), "Timed-out service reported as available");
    require(!controls.audioAvailable() && controls.volume() == 0, "Stale audio state was retained");
    require(controls.bluetoothAvailable() && controls.bluetoothEnabled(), "Bluetooth parsing failed");

    command(directory.path(), "nmcli", "echo disabled\n");
    controls.refresh();
    wait(500);
    require(controls.networkAvailable() && !controls.wifiEnabled(), "Refresh did not recover after timeout");
    qInfo("PASS: locale, availability, timeout, GUI responsiveness and recovery");
}
