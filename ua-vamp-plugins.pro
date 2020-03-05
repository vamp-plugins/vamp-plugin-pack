
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/ua-vamp-plugins

OBJECTS_DIR = ua-vamp-plugins/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk $$PWD/ua-vamp-plugins/src

QMAKE_CXXFLAGS -= -Werror

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/ua-vamp-plugins/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/ua-vamp-plugins/vamp-plugin.map -Wl,-no-undefined
}
macx* {
    LIBS += -exported_symbols_list $$PWD/ua-vamp-plugins/vamp-plugin.list
}

QMAKE_POST_LINK += $$DEPLOYDIR/mark-for-signing out

!win* {
    QMAKE_POST_LINK += && \
        cp ua-vamp-plugins/ua-vamp-plugins.cat out/ && \
        cp ua-vamp-plugins/LICENSE out/ua-vamp-plugins_COPYING.txt && \
        cp ua-vamp-plugins/readme.md out/ua-vamp-plugins_README.md
}

SOURCES += \
    ua-vamp-plugins/onsetsUA.cpp \
    ua-vamp-plugins/mf0UA.cpp \
    ua-vamp-plugins/plugins.cpp \
    ua-vamp-plugins/src/myfft.cpp \
    ua-vamp-plugins/src/bands.cpp \
    ua-vamp-plugins/src/onsetdetection.cpp \
    ua-vamp-plugins/src/combination.cpp \
    ua-vamp-plugins/src/spectralpattern.cpp \
    ua-vamp-plugins/src/peaksatt.cpp \
    ua-vamp-plugins/src/graph.cpp \
    ua-vamp-plugins/src/mf0.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp


