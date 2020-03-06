
TEMPLATE = lib

include(plugin.pri)

TARGET = out/segmentino

OBJECTS_DIR = segmentino/o

INCLUDEPATH += $$PWD/qm-vamp-plugins/lib $$PWD/qm-vamp-plugins/lib/qm-dsp $$PWD/qm-vamp-plugins/lib/qm-dsp/ext/kissfft $$PWD/qm-vamp-plugins/lib/qm-dsp/ext/kissfft/tools $$PWD/segmentino/armadillo-3.900.4/include

DEFINES += kiss_fft_scalar=double

!win* {
    QMAKE_POST_LINK += && \
        cp segmentino/segmentino.cat segmentino/segmentino.n3 out/ && \
        cp segmentino/CITATION out/segmentino_CITATION.txt && \
        cp segmentino/README out/segmentino_README.txt && \
        cp segmentino/COPYING out/segmentino_COPYING.txt
}

SOURCES += \
           segmentino/segmentino/Segmentino.cpp \
           segmentino/segmentino/libmain.cpp \
           nnls-chroma/chromamethods.cpp \
           nnls-chroma/nnls.c \
	   vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
	   vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp \
	   qm-vamp-plugins/lib/qm-dsp/dsp/onsets/DetectionFunction.cpp \
	   qm-vamp-plugins/lib/qm-dsp/dsp/onsets/PeakPicking.cpp \
	   qm-vamp-plugins/lib/qm-dsp/dsp/transforms/FFT.cpp \
	   qm-vamp-plugins/lib/qm-dsp/dsp/rateconversion/Decimator.cpp \
	   qm-vamp-plugins/lib/qm-dsp/dsp/tempotracking/TempoTrackV2.cpp \
	   qm-vamp-plugins/lib/qm-dsp/dsp/tempotracking/DownBeat.cpp \
	   qm-vamp-plugins/lib/qm-dsp/dsp/phasevocoder/PhaseVocoder.cpp \
           qm-vamp-plugins/lib/qm-dsp/dsp/signalconditioning/DFProcess.cpp \
           qm-vamp-plugins/lib/qm-dsp/dsp/signalconditioning/FiltFilt.cpp \
           qm-vamp-plugins/lib/qm-dsp/dsp/signalconditioning/Filter.cpp \
	   qm-vamp-plugins/lib/qm-dsp/maths/MathUtilities.cpp \
           qm-vamp-plugins/lib/qm-dsp/ext/kissfft/kiss_fft.c \
           qm-vamp-plugins/lib/qm-dsp/ext/kissfft/tools/kiss_fftr.c
