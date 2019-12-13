
TEMPLATE = app

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG += release warn_on c++14

QT += gui widgets svg

TARGET = "Vamp Plugin Pack Installer"
linux*:TARGET=vamp-plugin-pack-installer

sign.target = $$PWD/out/.signed
sign.depends = $$PWD/out/.something-to-sign
sign.commands = $$PWD/deploy/sign-plugin $$PWD/out

QMAKE_EXTRA_TARGETS += sign
PRE_TARGETDEPS += $$sign.target

