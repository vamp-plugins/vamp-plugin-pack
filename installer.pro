
TEMPLATE = app

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

QMAKE_CXXFLAGS_RELEASE -= -flto
QMAKE_LFLAGS_RELEASE -= -flto

CONFIG += release warn_on c++14

QT += gui widgets svg

TARGET = "Vamp Plugin Pack Installer"
linux*:TARGET=vamp-plugin-pack-installer

OBJECTS_DIR = o
MOC_DIR = o
RCC_DIR = o

sign.target = $$PWD/out/.signed
sign.depends = $$PWD/out/.something-to-sign
sign.commands = $$DEPLOYDIR/sign-plugins $$PWD/out

QMAKE_EXTRA_TARGETS += sign
PRE_TARGETDEPS += $$sign.target

qrc.target = $$PWD/installer.qrc
qrc.depends = $$PWD/installer.qrc.in
qrc.commands = $$DEPLOYDIR/generate-qrc $$PWD/installer.qrc

QMAKE_EXTRA_TARGETS += qrc
PRE_TARGETDEPS += $$qrc.target

# We can't use use RESOURCES += installer.qrc here, as qmake will
# reject a resource file that hasn't been generated yet

qtPrepareTool(QMAKE_RCC, rcc)

qrc_cpp.target = $${RCC_DIR}/qrc_installer.cpp
qrc_cpp.depends = $$qrc.target
qrc_cpp.commands = $$QMAKE_RCC $$qrc.target -o $$qrc_cpp.target

QMAKE_EXTRA_TARGETS += qrc_cpp
PRE_TARGETDEPS += $$qrc_cpp.target

SOURCES += \
        installer.cpp \
        $$qrc_cpp.target \
        vamp-plugin-sdk/src/vamp-hostsdk/Files.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/host-c.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginBufferingAdapter.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginChannelAdapter.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginHostAdapter.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginInputDomainAdapter.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginLoader.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginSummarisingAdapter.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/PluginWrapper.cpp \
        vamp-plugin-sdk/src/vamp-hostsdk/RealTime.cpp

DATAQUAY_SOURCES=$$fromfile(dataquay/lib.pro, SOURCES)
DATAQUAY_HEADERS=$$fromfile(dataquay/lib.pro, HEADERS)

for (file, DATAQUAY_SOURCES) { SOURCES += $$sprintf("dataquay/%1", $$file) }
for (file, DATAQUAY_HEADERS) { HEADERS += $$sprintf("dataquay/%1", $$file) }

DEFINES += HAVE_SORD HAVE_SERD USE_SORD NDEBUG

linux* {
    QMAKE_CXXFLAGS += -I/usr/include/sord-0 -I/usr/include/serd-0
    LIBS += -lsord-0 -lserd-0 -ldl
}

macx* {
    LIBS += -lsord-0 -lserd-0
    QMAKE_POST_LINK += deploy/osx/deploy.sh $$shell_quote($$TARGET)
}

win32* {
    LIBS += -lsord -lserd
}
    
