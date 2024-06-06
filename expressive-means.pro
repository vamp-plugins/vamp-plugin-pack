
TEMPLATE = lib

include(plugin.pri)

CONFIG += c++14

TARGET = out/expressive-means

OBJECTS_DIR = expressive-means/o

INCLUDEPATH += $$PWD/expressive-means/qm-dsp 

DEFINES += EXPRESSIVE_MEANS_VERSION="1.0.0"
DEFINES += EXPRESSIVE_MEANS_PLUGIN_VERSION=5

win32-msvc* {
    DEFINES += __restrict__=__restrict
}

!win* {
    QMAKE_POST_LINK += && \
        cp expressive-means/expressive-means.cat expressive-means/expressive-means.n3 out/ &&\
        cp expressive-means/COPYING out/expressive-means_COPYING.txt && \
        cp expressive-means/README.md out/expressive-means_README.md
}

SOURCES += \
	expressive-means/src/Articulation.cpp \
	expressive-means/src/CoreFeatures.cpp \
	expressive-means/src/Glide.cpp \
	expressive-means/src/Onsets.cpp \
	expressive-means/src/PitchVibrato.cpp \
	expressive-means/src/Portamento.cpp \
	expressive-means/src/SemanticArticulation.cpp \
	expressive-means/src/SemanticOnsets.cpp \
	expressive-means/src/SemanticPitchVibrato.cpp \
	expressive-means/src/SemanticPortamento.cpp \
	expressive-means/ext/qm-dsp/maths/MathUtilities.cpp \
	expressive-means/ext/pyin/PyinVamp.cpp \
	expressive-means/ext/pyin/YinVamp.cpp \
	expressive-means/ext/pyin/LocalCandidatePYIN.cpp \
	expressive-means/ext/pyin/Yin.cpp \
	expressive-means/ext/pyin/YinUtil.cpp \
	expressive-means/ext/pyin/MonoNote.cpp \
	expressive-means/ext/pyin/MonoNoteParameters.cpp \
	expressive-means/ext/pyin/SparseHMM.cpp \
	expressive-means/ext/pyin/MonoNoteHMM.cpp \
	expressive-means/ext/pyin/MonoPitchHMM.cpp \
        expressive-means/src/libmain.cpp \
        vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
        vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp \
        vamp-plugin-sdk/src/vamp-sdk/FFT.cpp

