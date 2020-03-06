
TEMPLATE = lib

include(plugin.pri)

TARGET = out/match-vamp-plugin

OBJECTS_DIR = match-vamp/o

DEFINES += USE_COMPACT_TYPES

!win* {
    QMAKE_POST_LINK += && \
        cp match-vamp/match-vamp-plugin.cat match-vamp/match-vamp-plugin.n3 out/ && \
        cp match-vamp/README   out/match-vamp-plugin_README.txt && \
        cp match-vamp/CITATION out/match-vamp-plugin_CITATION.txt && \
        cp match-vamp/COPYING  out/match-vamp-plugin_COPYING.txt
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


