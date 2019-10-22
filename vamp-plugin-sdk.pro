
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG += staticlib

TARGET = vamp-sdk

HEADERS += \
        vamp-plugin-sdk/vamp-sdk/Plugin.h \
        vamp-plugin-sdk/vamp-sdk/PluginAdapter.h \
        vamp-plugin-sdk/vamp-sdk/PluginBase.h \
        vamp-plugin-sdk/vamp-sdk/RealTime.h \
        vamp-plugin-sdk/vamp-sdk/FFT.h

SOURCES +=  \
        vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
        vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp \
        vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
        vamp-plugin-sdk/src/vamp-sdk/acsymbols.c

repoint.target = $$PWD/.repoint.point
repoint.depends = $$PWD/repoint-project.json $$PWD/repoint-lock.json
repoint.commands = $$PWD/repoint install --directory $$PWD

QMAKE_EXTRA_TARGETS += repoint
PRE_TARGETDEPS += $$repoint.target
