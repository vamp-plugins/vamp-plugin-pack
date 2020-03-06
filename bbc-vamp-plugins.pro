
TEMPLATE = lib

include(plugin.pri)

TARGET = out/bbc-vamp-plugins

OBJECTS_DIR = bbc-vamp-plugins/o

!win* {
    QMAKE_POST_LINK += && \
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
    
