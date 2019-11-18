
CONFIG += c++11

CONFIG += release

PREFIX_PATH = /usr/local

INCLUDEPATH += $$PWD/vamp-plugin-sdk

win32-msvc* {

    # This config is actually used only for 64-bit Windows builds.
    
    INCLUDEPATH += /Libraries/boost_1_69_0 $$PWD/../boost_1_69_0/

    CONFIG(release) {
        LIBS += -NODEFAULTLIB:LIBCMT -Lrelease
    }

    DEFINES += NOMINMAX _USE_MATH_DEFINES
}

macx* {

    # All Mac builds are 64-bit these days.

    INCLUDEPATH += 
    LIBS += -L$$PWD

    INCLUDEPATH += /usr/local/opt/boost/include

    QMAKE_CXXFLAGS_RELEASE += -O3 -flto
    QMAKE_LFLAGS_RELEASE += -O3 -flto
}

linux* {
    QMAKE_CXXFLAGS_RELEASE += -O3
    QMAKE_LFLAGS_RELEASE += -O3
}

