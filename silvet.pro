
TEMPLATE = lib

include(plugin.pri)

TARGET = out/silvet

OBJECTS_DIR = silvet/o

INCLUDEPATH += $$PWD/silvet $$PWD/silvet/bqvec $$PWD/silvet/bqvec/bqvec $$PWD/constant-q-cpp $$PWD/constant-q-cpp/cq $$PWD/constant-q-cpp/src/ext/kissfft $$PWD/constant-q-cpp/src/ext/kissfft/tools $$PWD/silvet/flattendynamics

DEFINES += kiss_fft_scalar=double

linux* {
    LIBS += -lpthread
}

!win* {
    QMAKE_POST_LINK += && \
        cp silvet/silvet.n3 silvet/silvet.cat out/ && \
        cp silvet/README   out/silvet_README.txt && \
        cp silvet/CITATION out/silvet_CITATION.txt && \
        cp silvet/COPYING  out/silvet_COPYING.txt
}

SOURCES += \
    silvet/src/Silvet.cpp \
    silvet/src/EM.cpp \
    silvet/src/Instruments.cpp \
    silvet/src/LiveInstruments.cpp \
    silvet/src/libmain.cpp \
    silvet/bqvec/src/Allocators.cpp \
    silvet/flattendynamics/flattendynamics-ladspa.cpp \
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
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

HEADERS += \
    silvet/src/Silvet.h

