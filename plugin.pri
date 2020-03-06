
exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt

win* {
    CONFIG += dll
}
!win* {
    CONFIG += plugin
}

CONFIG += no_plugin_name_prefix release warn_on

QMAKE_CXXFLAGS -= -Werror

INCLUDEPATH += $$PWD/vamp-plugin-sdk

# 
win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/vamp-plugin-sdk/skeleton/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/vamp-plugin-sdk/skeleton/vamp-plugin.map -Wl,-no-undefined
}
macx* {
    LIBS += -exported_symbols_list $$PWD/vamp-plugin-sdk/skeleton/vamp-plugin.list
}

QMAKE_POST_LINK += $$DEPLOYDIR/mark-for-signing out

