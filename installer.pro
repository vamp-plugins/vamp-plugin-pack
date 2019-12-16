
TEMPLATE = app

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

QMAKE_CXXFLAGS_RELEASE -= -flto
QMAKE_LFLAGS_RELEASE -= -flto

CONFIG += release warn_on c++14

QT += gui widgets svg

TARGET = "Vamp Plugin Pack Installer"
linux*:TARGET=vamp-plugin-pack-installer

OBJECTS_DIR = o
MOC_DIR = o
RCC_DIR = o

RESOURCES += installer.qrc

sign.target = $$PWD/out/.signed
sign.depends = $$PWD/out/.something-to-sign
sign.commands = $$DEPLOYDIR/sign-plugins $$PWD/out

QMAKE_EXTRA_TARGETS += sign
PRE_TARGETDEPS += $$sign.target

SOURCES += installer.cpp

