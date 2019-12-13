
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/nnls-chroma

OBJECTS_DIR = nnls-chroma/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk

QMAKE_CXXFLAGS -= -Werror

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/nnls-chroma/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/nnls-chroma/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/nnls-chroma/vamp-plugin.list
}

QMAKE_POST_LINK += $$PWD/deploy/sign-plugin $${PWD}/$${TARGET}.$${QMAKE_EXTENSION_SHLIB}

!win* {
    QMAKE_POST_LINK += && \
        cp nnls-chroma/nnls-chroma.cat nnls-chroma/nnls-chroma.n3 out/ && \
        cp nnls-chroma/README   out/nnls-chroma_README.txt && \
        cp nnls-chroma/CITATION out/nnls-chroma_CITATION.txt && \
        cp nnls-chroma/COPYING  out/nnls-chroma_COPYING.txt
}

SOURCES += \
    nnls-chroma/chromamethods.cpp \
    nnls-chroma/NNLSBase.cpp \
    nnls-chroma/NNLSChroma.cpp \
    nnls-chroma/Chordino.cpp \
    nnls-chroma/Tuning.cpp \
    nnls-chroma/plugins.cpp \
    nnls-chroma/nnls.c \
    nnls-chroma/viterbi.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

HEADERS += \
    nnls-chroma/chromamethods.h \
    nnls-chroma/NNLSBase.h \
    nnls-chroma/NNLSChroma.h \
    nnls-chroma/Chordino.h \
    nnls-chroma/Tuning.h \
    nnls-chroma/nnls.h \
    nnls-chroma/viterbi.h

