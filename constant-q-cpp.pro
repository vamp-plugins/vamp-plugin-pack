
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/cqvamp

OBJECTS_DIR = constant-q-cpp/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk $$PWD/constant-q-cpp $$PWD/constant-q-cpp/cq $$PWD/constant-q-cpp/src $$PWD/constant-q-cpp/src/ext/kissfft $$PWD/constant-q-cpp/src/ext/kissfft/tools

DEFINES += kiss_fft_scalar=double

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/constant-q-cpp/vamp/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/constant-q-cpp/vamp/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/constant-q-cpp/vamp/vamp-plugin.list
}

QMAKE_POST_LINK += $$DEPLOYDIR/mark-for-signing $$PWD/out

!win* {
    QMAKE_POST_LINK += && \
        cp constant-q-cpp/cqvamp.cat out/ && \
        cp constant-q-cpp/cqvamp.n3 out/ && \
        cp constant-q-cpp/COPYING out/cqvamp_COPYING.txt && \
        cp constant-q-cpp/README out/cqvamp_README.txt && \
        cp constant-q-cpp/CITATION out/cqvamp_CITATION.txt
}

SOURCES += \
    constant-q-cpp/src/CQKernel.cpp \
    constant-q-cpp/src/ConstantQ.cpp \
    constant-q-cpp/src/CQSpectrogram.cpp \
    constant-q-cpp/src/CQInverse.cpp \
    constant-q-cpp/src/Chromagram.cpp \
    constant-q-cpp/src/Pitch.cpp \
    constant-q-cpp/src/dsp/FFT.cpp \
    constant-q-cpp/src/dsp/KaiserWindow.cpp \
    constant-q-cpp/src/dsp/MathUtilities.cpp \
    constant-q-cpp/src/dsp/Resampler.cpp \
    constant-q-cpp/src/dsp/SincWindow.cpp \
    constant-q-cpp/src/ext/kissfft/kiss_fft.c \
    constant-q-cpp/src/ext/kissfft/tools/kiss_fftr.c \
    constant-q-cpp/vamp/CQVamp.cpp \
    constant-q-cpp/vamp/CQChromaVamp.cpp \
    constant-q-cpp/vamp/libmain.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp
