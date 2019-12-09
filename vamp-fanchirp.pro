
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/fanchirp

OBJECTS_DIR = vamp-fanchirp/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk $$PWD/vamp-fanchirp/bqvec

QMAKE_CXXFLAGS -= -Werror

win32-msvc* {
    LIBS += -L$$PWD/sv-dependency-builds/win64-msvc/lib -lfftw3
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/vamp-fanchirp/vamp-plugin.map
}
linux* {
    LIBS += -Wl,-Bstatic -Lsv-dependency-builds/linux/lib/fftw-3.3.8-x86_64 -lfftw3 -Wl,-Bdynamic -Wl,--version-script=$$PWD/vamp-fanchirp/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/vamp-fanchirp/vamp-plugin.list
}
!win* {
    QMAKE_POST_LINK += \
        cp vamp-fanchirp/fanchirp.cat out/ && \
        cp vamp-fanchirp/README.md out/fanchirp_README.md && \
        cp vamp-fanchirp/CITATION  out/fanchirp_CITATION.txt && \
        cp vamp-fanchirp/COPYING   out/fanchirp_COPYING.txt
}

SOURCES += \
    vamp-fanchirp/FChTransformF0gram.cpp \
    vamp-fanchirp/FChTransformUtils.cpp \
    vamp-fanchirp/plugins.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp



