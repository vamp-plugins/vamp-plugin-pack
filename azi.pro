
TEMPLATE = lib

include(plugin.pri)

TARGET = out/azi

OBJECTS_DIR = azi/o

QMAKE_CXXFLAGS -= -Werror

!win* {
    QMAKE_POST_LINK += && \
        cp azi/azi.cat out/ && \
        cp azi/COPYING out/azi_COPYING.txt
}

SOURCES += \
    azi/Azi.cpp \
    azi/plugins.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

HEADERS += \
    azi/Azi.h

