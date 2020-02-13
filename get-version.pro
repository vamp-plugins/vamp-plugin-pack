
TEMPLATE = app

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG += console release warn_on c++14

QT -= gui widgets svg

win32-x-g++:QMAKE_LFLAGS += -Wl,-subsystem,console
macx*: CONFIG -= app_bundle

TARGET=out/get-version

OBJECTS_DIR = o
MOC_DIR = o
RCC_DIR = o

SOURCES += \
        get-version.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/Files.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/host-c.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginBufferingAdapter.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginChannelAdapter.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginHostAdapter.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginInputDomainAdapter.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginLoader.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginSummarisingAdapter.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginWrapper.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/RealTime.cpp

linux* {
    LIBS += -ldl
}

