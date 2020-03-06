
TEMPLATE = lib

include(plugin.pri)

TARGET = out/vamp-example-plugins

OBJECTS_DIR = vamp-plugin-sdk/o

!win* {
    QMAKE_POST_LINK += && \
        cp vamp-plugin-sdk/examples/vamp-example-plugins.cat vamp-plugin-sdk/examples/vamp-example-plugins.n3 out/ && \
        cp vamp-plugin-sdk/COPYING out/vamp-example-plugins_COPYING.txt
}

SOURCES += \
    vamp-plugin-sdk/examples/AmplitudeFollower.cpp \
    vamp-plugin-sdk/examples/FixedTempoEstimator.cpp \
    vamp-plugin-sdk/examples/PercussionOnsetDetector.cpp \
    vamp-plugin-sdk/examples/PowerSpectrum.cpp \
    vamp-plugin-sdk/examples/SpectralCentroid.cpp \
    vamp-plugin-sdk/examples/ZeroCrossing.cpp \
    vamp-plugin-sdk/examples/plugins.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

