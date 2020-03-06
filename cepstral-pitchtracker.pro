
TEMPLATE = lib

include(plugin.pri)

TARGET = out/cepstral-pitchtracker

OBJECTS_DIR = cepstral-pitchtracker/o

!win* {
    QMAKE_POST_LINK += && \
        cp cepstral-pitchtracker/cepstral-pitchtracker.cat out/ && \
        cp cepstral-pitchtracker/cepstral-pitchtracker.n3 out/ && \
        cp cepstral-pitchtracker/README out/cepstral-pitchtracker_README.txt && \
        cp cepstral-pitchtracker/COPYING out/cepstral-pitchtracker_COPYING.txt
}

SOURCES += \
    cepstral-pitchtracker/CepstralPitchTracker.cpp \
    cepstral-pitchtracker/AgentFeeder.cpp \
    cepstral-pitchtracker/NoteHypothesis.cpp \
    cepstral-pitchtracker/PeakInterpolator.cpp \
    cepstral-pitchtracker/libmain.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

    
