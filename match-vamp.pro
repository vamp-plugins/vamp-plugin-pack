
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = match-vamp-plugin

OBJECTS_DIR = match-vamp/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk

QMAKE_CXXFLAGS -= -Werror

DEFINES += USE_COMPACT_TYPES

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/match-vamp/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/match-vamp/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/match-vamp/vamp-plugin.list
}

SOURCES += \
    match-vamp/src/DistanceMetric.cpp \
    match-vamp/src/FeatureConditioner.cpp \
    match-vamp/src/FeatureExtractor.cpp \
    match-vamp/src/Finder.cpp \
    match-vamp/src/Matcher.cpp \
    match-vamp/src/MatchFeatureFeeder.cpp \
    match-vamp/src/MatchPipeline.cpp \
    match-vamp/src/MatchVampPlugin.cpp \
    match-vamp/src/Path.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

HEADERS += \
    match-vamp/src/DistanceMetric.h \
    match-vamp/src/FeatureConditioner.h \
    match-vamp/src/FeatureExtractor.h \
    match-vamp/src/Finder.h \
    match-vamp/src/Matcher.h \
    match-vamp/src/MatchFeatureFeeder.h \
    match-vamp/src/MatchPipeline.h \
    match-vamp/src/MatchTypes.h \
    match-vamp/src/MatchVampPlugin.h \
    match-vamp/src/Path.h


