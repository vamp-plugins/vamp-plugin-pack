
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/vampy

OBJECTS_DIR = vampy/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk

QMAKE_CXXFLAGS -= -Werror

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/vampy/vamp-plugin.map
}
linux* {
    QMAKE_CXXFLAGS += -DHAVE_NUMPY \
        -D_DEBUG -fno-strict-aliasing \
        -I/usr/include/python2.7 \
        -I/usr/lib/python2.7/dist-packages/numpy/core/include \
        -I/usr/lib/python2.7/site-packages/numpy/core/include
    LIBS += -lpython2.7 -ldl -Wl,--version-script=$$PWD/vampy/vamp-plugin.map
}
macx* {
    QMAKE_CXXFLAGS += -DHAVE_NUMPY \
        -D_DEBUG \
        -I/System/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7 \
        -I/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/numpy/core/include
    LIBS += -lpython2.7 -lpthread -exported_symbols_list $$PWD/vampy/vamp-plugin.list
}

QMAKE_POST_LINK += $$PWD/deploy/sign-plugin $${PWD}/$${TARGET}.$${QMAKE_EXTENSION_SHLIB}

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
