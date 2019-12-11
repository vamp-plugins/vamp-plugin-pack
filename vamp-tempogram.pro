
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/tempogram

OBJECTS_DIR = vamp-tempogram/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk

QMAKE_CXXFLAGS -= -Werror

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/vamp-tempogram/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/vamp-tempogram/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/vamp-tempogram/vamp-plugin.list
}
!win* {
    QMAKE_POST_LINK += \
        cp vamp-tempogram/tempogram.cat vamp-tempogram/tempogram.n3 out/ && \
        cp vamp-tempogram/README out/tempogram_README.txt && \
        cp vamp-tempogram/CITATION out/tempogram_CITATION.txt && \
        cp vamp-tempogram/COPYING out/tempogram_COPYING.txt
}

SOURCES += \
    vamp-tempogram/TempogramPlugin.cpp \
    vamp-tempogram/FIRFilter.cpp \
    vamp-tempogram/WindowFunction.cpp \
    vamp-tempogram/NoveltyCurveProcessor.cpp \
    vamp-tempogram/SpectrogramProcessor.cpp \
    vamp-tempogram/AutocorrelationProcessor.cpp \
    vamp-tempogram/plugins.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp


