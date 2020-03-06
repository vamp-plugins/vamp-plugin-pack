TEMPLATE = lib

include(plugin.pri)

TARGET = out/tuning-difference

OBJECTS_DIR = tuning-difference/o

INCLUDEPATH += $$PWD/constant-q-cpp $$PWD/constant-q-cpp/cq $$PWD/constant-q-cpp/src/ext/kissfft $$PWD/constant-q-cpp/src/ext/kissfft/tools

DEFINES += kiss_fft_scalar=double

!win* {
    QMAKE_POST_LINK += && \
        cp tuning-difference/tuning-difference.cat tuning-difference/tuning-difference.n3 out/ && \
        cp tuning-difference/COPYING out/tuning-difference_COPYING.txt && \
        cp tuning-difference/README.md out/tuning-difference_README.md
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
    tuning-difference/src/TuningDifference.cpp \
    tuning-difference/src/plugins.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

HEADERS += \
    tuning-difference/src/TuningDifference.h

