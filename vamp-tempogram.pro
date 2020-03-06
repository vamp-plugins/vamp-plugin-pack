
TEMPLATE = lib

include(plugin.pri)

TARGET = out/tempogram

OBJECTS_DIR = vamp-tempogram/o


!win* {
    QMAKE_POST_LINK += && \
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


