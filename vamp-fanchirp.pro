
TEMPLATE = lib

include(plugin.pri)

TARGET = out/fanchirp

OBJECTS_DIR = vamp-fanchirp/o

INCLUDEPATH += $$PWD/vamp-fanchirp/bqvec

!win* {
    QMAKE_POST_LINK += && \
        cp vamp-fanchirp/fanchirp.cat out/ && \
        cp vamp-fanchirp/README.md out/fanchirp_README.md && \
        cp vamp-fanchirp/CITATION  out/fanchirp_CITATION.txt && \
        cp vamp-fanchirp/COPYING   out/fanchirp_COPYING.txt
}

SOURCES += \
    vamp-fanchirp/FChTransformF0gram.cpp \
    vamp-fanchirp/FChTransformUtils.cpp \
    vamp-fanchirp/plugins.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

