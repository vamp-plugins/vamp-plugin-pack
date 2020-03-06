TEMPLATE = lib

include(plugin.pri)

TARGET = out/pyin

OBJECTS_DIR = pyin/o

linux* {
    QMAKE_CXXFLAGS_RELEASE += -ffast-math
}
macx* {
    QMAKE_CXXFLAGS_RELEASE += -ffast-math
}

!win* {
    QMAKE_POST_LINK += && \
        cp pyin/pyin.cat pyin/pyin.n3 out/ && \
        cp pyin/README  out/pyin_README.txt && \
        cp pyin/COPYING out/pyin_COPYING.txt
}

SOURCES += \
    pyin/YinUtil.cpp \
    pyin/Yin.cpp \
    pyin/SparseHMM.cpp \
    pyin/MonoPitchHMM.cpp \
    pyin/MonoNoteParameters.cpp \
    pyin/MonoNoteHMM.cpp \
    pyin/MonoNote.cpp \
    pyin/libmain.cpp \
    pyin/YinVamp.cpp \
    pyin/PYinVamp.cpp \
    pyin/LocalCandidatePYIN.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

HEADERS += \
    pyin/YinUtil.h \
    pyin/Yin.h \
    pyin/SparseHMM.h \
    pyin/MonoPitchHMM.h \
    pyin/MonoNoteParameters.h \
    pyin/MonoNoteHMM.h \
    pyin/MonoNote.h \
    pyin/MeanFilter.h \
    pyin/YinVamp.h \
    pyin/PYinVamp.h \
    pyin/LocalCandidatePYIN.h

