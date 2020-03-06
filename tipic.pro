
TEMPLATE = lib

include(plugin.pri)

TARGET = out/tipic

OBJECTS_DIR = tipic/o

INCLUDEPATH += $$PWD/tipic/qm-dsp $$PWD/tipic/qm-dsp/ext/kissfft $$PWD/tipic/qm-dsp/ext/kissfft/tools

DEFINES += kiss_fft_scalar=double

win32-msvc* {
    DEFINES += __restrict__=__restrict
}

!win* {
    QMAKE_POST_LINK += && \
        cp tipic/tipic.cat tipic/tipic.n3 out/ &&\
        cp tipic/COPYING out/tipic_COPYING.txt && \
        cp tipic/CITATION out/tipic_CITATION.txt && \
        cp tipic/README.txt out/tipic_README.txt
}

SOURCES += \
	tipic/src/PitchFilterbank.cpp \
	tipic/src/CRP.cpp \
	tipic/src/Chroma.cpp \
	tipic/src/FeatureDownsample.cpp \
	tipic/src/CENS.cpp \
	tipic/qm-dsp/dsp/signalconditioning/Filter.cpp \
	tipic/qm-dsp/dsp/transforms/DCT.cpp \
	tipic/qm-dsp/dsp/transforms/FFT.cpp \
	tipic/qm-dsp/dsp/rateconversion/Resampler.cpp \
	tipic/qm-dsp/maths/MathUtilities.cpp \
	tipic/qm-dsp/base/KaiserWindow.cpp \
	tipic/qm-dsp/base/SincWindow.cpp \
	tipic/qm-dsp/ext/kissfft/kiss_fft.c \
	tipic/qm-dsp/ext/kissfft/tools/kiss_fftr.c \
        tipic/src/TipicVampPlugin.cpp \
        tipic/src/libmain.cpp \
        vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
        vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

