
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/cepstral-pitchtracker

OBJECTS_DIR = cepstral-pitchtracker/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk

QMAKE_CXXFLAGS -= -Werror

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/cepstral-pitchtracker/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/cepstral-pitchtracker/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/cepstral-pitchtracker/vamp-plugin.list
}
!win* {
    QMAKE_POST_LINK += \
        cp cepstral-pitchtracker/cepstral-pitchtracker.cat out/ && \
        cp cepstral-pitchtracker/cepstral-pitchtracker.n3 out/ && \
        cp cepstral-pitchtracker/README out/cepstral-pitchtracker_README.txt
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

    
