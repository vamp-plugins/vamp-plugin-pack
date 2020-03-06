
TEMPLATE = lib

include(plugin.pri)

TARGET = out/vamp-libxtract

OBJECTS_DIR = vamp-libxtract-plugins/o

INCLUDEPATH += $$PWD/vamp-libxtract-plugins/LibXtract

win32-msvc* {
    DEFINES += XTRACT_FFT=1 USE_OOURA=1 NDEBUG
}
win32-g++* {
    DEFINES += XTRACT_FFT=1 USE_OOURA=1 NDEBUG
}
linux* {
    DEFINES += XTRACT_FFT=1 USE_OOURA=1 NDEBUG
}
macx* {
    DEFINES += XTRACT_FFT=1 NDEBUG
    LIBS += -framework Accelerate
}

!win* {
    QMAKE_POST_LINK += && \
        cp vamp-libxtract-plugins/vamp-libxtract.cat vamp-libxtract-plugins/vamp-libxtract.n3 out/ && \
        cp vamp-libxtract-plugins/COPYING out/vamp-libxtract_COPYING.txt && \
        cp vamp-libxtract-plugins/README out/vamp-libxtract_README.txt
}

SOURCES += \
    vamp-libxtract-plugins/LibXtract/src/delta.c \
    vamp-libxtract-plugins/LibXtract/src/descriptors.c \
    vamp-libxtract-plugins/LibXtract/src/fini.c \
    vamp-libxtract-plugins/LibXtract/src/helper.c \
    vamp-libxtract-plugins/LibXtract/src/init.c \
    vamp-libxtract-plugins/LibXtract/src/libxtract.c \
    vamp-libxtract-plugins/LibXtract/src/scalar.c \
    vamp-libxtract-plugins/LibXtract/src/vector.c \
    vamp-libxtract-plugins/LibXtract/src/window.c \
    vamp-libxtract-plugins/LibXtract/src/dywapitchtrack/dywapitchtrack.c \
    vamp-libxtract-plugins/LibXtract/src/ooura/fftsg.c \
    vamp-libxtract-plugins/plugins/XtractPlugin.cpp \
    vamp-libxtract-plugins/libmain.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp
    
