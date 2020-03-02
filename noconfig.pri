
CONFIG += c++11

CONFIG += release

PREFIX_PATH = /usr/local

INCLUDEPATH += $$PWD/vamp-plugin-sdk

win32-msvc* {

    # This config is actually used only for 64-bit Windows builds.

    DEPLOYDIR = $$PWD/deploy/win64

    INCLUDEPATH += /Libraries/boost_1_69_0 $$PWD/../boost_1_69_0/ $$PWD/sv-dependency-builds/win64-msvc/include
    LIBS += -L$$PWD -L$$PWD/sv-dependency-builds/win64-msvc/lib

    CONFIG(release) {
        LIBS += -NODEFAULTLIB:MSVCRT -Lrelease
    }

    DEFINES += NOMINMAX _USE_MATH_DEFINES HAVE_C99_VARARGS_MACROS _HAS_STD_BYTE=0

    LIBS += -lWindowsApp
}

macx* {

    # All Mac builds are 64-bit these days.

    DEPLOYDIR = $$PWD/deploy/osx

    INCLUDEPATH += /usr/local/opt/boost/include $$PWD/sv-dependency-builds/osx/include
    LIBS += -L$$PWD -L$$PWD/sv-dependency-builds/osx/lib

    QMAKE_CXXFLAGS_RELEASE += -O3 -flto
    QMAKE_LFLAGS_RELEASE += -O3 -flto
}

linux* {

    DEPLOYDIR = $$PWD/deploy/linux

    QMAKE_CXXFLAGS_RELEASE += -O3 -flto
    QMAKE_LFLAGS_RELEASE += -O3 -flto -Wl,--no-undefined
}

