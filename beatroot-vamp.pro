
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/beatroot-vamp

OBJECTS_DIR = beatroot-vamp/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk

QMAKE_CXXFLAGS -= -Werror

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/beatroot-vamp/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/beatroot-vamp/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/beatroot-vamp/vamp-plugin.list
}

QMAKE_POST_LINK += $$DEPLOYDIR/mark-for-signing out

!win* {
    QMAKE_POST_LINK += && \
        cp beatroot-vamp/beatroot-vamp.cat beatroot-vamp/beatroot-vamp.n3 out/ && \
        cp beatroot-vamp/README   out/beatroot-vamp_README.txt && \
        cp beatroot-vamp/CITATION out/beatroot-vamp_CITATION.txt && \
        cp beatroot-vamp/COPYING  out/beatroot-vamp_COPYING.txt
}

SOURCES += \
    beatroot-vamp/BeatRootProcessor.cpp \
    beatroot-vamp/BeatRootVampPlugin.cpp \
    beatroot-vamp/Peaks.cpp \
    beatroot-vamp/Agent.cpp \
    beatroot-vamp/AgentList.cpp \
    beatroot-vamp/Induction.cpp \
    beatroot-vamp/BeatTracker.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp



