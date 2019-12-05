
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/bbc-vamp-plugins

OBJECTS_DIR = bbc-vamp-plugins/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk

QMAKE_CXXFLAGS -= -Werror

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/bbc-vamp-plugins/src/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/bbc-vamp-plugins/src/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/bbc-vamp-plugins/src/vamp-plugin.list
}
!win* {
    QMAKE_POST_LINK += \
        cp bbc-vamp-plugins/bbc-vamp-plugins.cat bbc-vamp-plugins/bbc-vamp-plugins.n3 out/ && \
        cp bbc-vamp-plugins/COPYING out/bbc-vamp-plugins_COPYING.txt && \
        cp bbc-vamp-plugins/README.md out/bbc-vamp-plugins_README.md
}

SOURCES += \
    bbc-vamp-plugins/src/Energy.cpp \
    bbc-vamp-plugins/src/Intensity.cpp \
    bbc-vamp-plugins/src/SpectralFlux.cpp \
    bbc-vamp-plugins/src/Rhythm.cpp \
    bbc-vamp-plugins/src/SpectralContrast.cpp \
    bbc-vamp-plugins/src/SpeechMusicSegmenter.cpp \
    bbc-vamp-plugins/src/Peaks.cpp \
    bbc-vamp-plugins/src/plugins.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp
    
