
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/vamp-example-plugins

OBJECTS_DIR = vamp-plugin-sdk/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk

QMAKE_CXXFLAGS -= -Werror

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/vamp-plugin-sdk/build/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/vamp-plugin-sdk/build/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/vamp-plugin-sdk/build/vamp-plugin.list
}

QMAKE_POST_LINK += $$DEPLOYDIR/mark-for-signing $$PWD/out

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

