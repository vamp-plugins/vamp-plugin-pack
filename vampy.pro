
TEMPLATE = lib

include(plugin.pri)

TARGET = out/vampy

OBJECTS_DIR = vampy/o

linux* {
    QMAKE_CXXFLAGS += -DHAVE_NUMPY \
        -D_DEBUG -fno-strict-aliasing \
        -I/usr/include/python2.7 \
        -I/usr/lib/python2.7/dist-packages/numpy/core/include \
        -I/usr/lib/python2.7/site-packages/numpy/core/include
    LIBS += -lpython2.7 -ldl
}
macx* {
    QMAKE_CXXFLAGS += -DHAVE_NUMPY \
        -D_DEBUG \
        -I/System/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7 \
        -I/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/numpy/core/include
    LIBS += -lpython2.7 -lpthread
}
win* {
    QMAKE_CXXFLAGS += -DHAVE_NUMPY \
        -DNDEBUG \
        -DVAMPY_EXPORTS \
        -I/Python27-64/include -I/Python27-64/Lib/site-packages/numpy-1.16.1-py2.7-win-amd64.egg/numpy/core/include
    LIBS += -L/Python27-64/libs -lpython27
}

!win* {
    QMAKE_POST_LINK += && \
        cp vampy/COPYING out/vampy_COPYING.txt && \
        cp vampy/README out/vampy_README.txt
}

SOURCES += \
    vampy/PyPlugin.cpp \
    vampy/PyPlugScanner.cpp \
    vampy/vampy-main.cpp \
    vampy/Mutex.cpp \
    vampy/PyTypeInterface.cpp \
    vampy/PyExtensionManager.cpp \
    vampy/PyExtensionModule.cpp \
    vampy/PyRealTime.cpp \
    vampy/PyFeature.cpp \
    vampy/PyParameterDescriptor.cpp \
    vampy/PyOutputDescriptor.cpp \
    vampy/PyFeatureSet.cpp \
    vamp-plugin-sdk/src/vamp-sdk/FFT.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp
