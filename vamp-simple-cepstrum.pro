
TEMPLATE = lib

include(plugin.pri)

TARGET = out/simple-cepstrum

OBJECTS_DIR = vamp-simple-cepstrum/o

!win* {
    QMAKE_POST_LINK += && \
        cp vamp-simple-cepstrum/simple-cepstrum.cat out/ && \
        cp vamp-simple-cepstrum/simple-cepstrum.n3 out/ && \
        cp vamp-simple-cepstrum/README out/simple-cepstrum_README.txt && \
        cp vamp-simple-cepstrum/COPYING out/simple-cepstrum_COPYING.txt
}

SOURCES += \
    vamp-simple-cepstrum/SimpleCepstrum.cpp \
    vamp-simple-cepstrum/libmain.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

    
