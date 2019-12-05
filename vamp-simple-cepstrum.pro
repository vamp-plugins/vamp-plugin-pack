
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/simple-cepstrum

OBJECTS_DIR = vamp-simple-cepstrum/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk

QMAKE_CXXFLAGS -= -Werror

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/vamp-simple-cepstrum/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/vamp-simple-cepstrum/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/vamp-simple-cepstrum/vamp-plugin.list
}
!win* {
    QMAKE_POST_LINK += \
        cp vamp-simple-cepstrum/simple-cepstrum.cat out/ && \
        cp vamp-simple-cepstrum/simple-cepstrum.n3 out/
}

SOURCES += \
    vamp-simple-cepstrum/SimpleCepstrum.cpp \
    vamp-simple-cepstrum/libmain.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

    