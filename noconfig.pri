
CONFIG += c++11

CONFIG += release

PREFIX_PATH = /usr/local

INCLUDEPATH += $$PWD/vamp-plugin-sdk

win32-msvc* {

    DEPLOYDIR = $$PWD/deploy/win64

    INCLUDEPATH += /Libraries/boost_1_69_0 $$PWD/../boost_1_69_0/ $$PWD/sv-dependency-builds/win64-msvc/include
    LIBS += -L$$PWD -L$$PWD/sv-dependency-builds/win64-msvc/lib

    CONFIG(release) {
        LIBS += -NODEFAULTLIB:MSVCRT -Lrelease
    }

    DEFINES += NOMINMAX _USE_MATH_DEFINES HAVE_C99_VARARGS_MACROS _HAS_STD_BYTE=0

    DEFINES += AVOID_WINRT_DEPENDENCY
}

macx* {

    # All Mac builds are 64-bit these days.

    DEPLOYDIR = $$PWD/deploy/osx

    INCLUDEPATH += /opt/boost/include /usr/local/opt/boost/include $$PWD/sv-dependency-builds/osx/include
    LIBS += -L$$PWD -L$$PWD/sv-dependency-builds/osx/lib

    QMAKE_CXXFLAGS_RELEASE += -O3 -flto
    QMAKE_LFLAGS_RELEASE += -O3 -flto
}

linux* {

    DEPLOYDIR = $$PWD/deploy/linux

    INCLUDEPATH += $$PWD/sv-dependency-builds/src/serd-0.18.2 $$PWD/sv-dependency-builds/src/sord-0.12.0
    
    QMAKE_CXXFLAGS_RELEASE += -O3 -flto
    QMAKE_LFLAGS_RELEASE += -O3 -flto -Wl,--no-undefined
}

