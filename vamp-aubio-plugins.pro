
TEMPLATE = lib

exists(config.pri) {
    include(config.pri)
}

!exists(config.pri) {
    include(noconfig.pri)
}

CONFIG -= qt
CONFIG += plugin no_plugin_name_prefix release warn_on

TARGET = out/vamp-aubio
OBJECTS_DIR = vamp-aubio-plugins/o

INCLUDEPATH += $$PWD/vamp-plugin-sdk $$PWD/aubio $$PWD/aubio-link $$PWD/aubio/src $$PWD/vamp-aubio-plugins/plugins

QMAKE_CXXFLAGS -= -Werror

DEFINES += HAVE_STDLIB_H HAVE_STDIO_H HAVE_MATH_H HAVE_STRING_H HAVE_ERRNO_H HAVE_LIMITS_H HAVE_STDARG_H

win32-msvc* {
    LIBS += -EXPORT:vampGetPluginDescriptor
}
win32-g++* {
    LIBS += -Wl,--version-script=$$PWD/vamp-aubio-plugins/vamp-plugin.map
}
linux* {
    LIBS += -Wl,--version-script=$$PWD/vamp-aubio-plugins/vamp-plugin.map
}
macx* {
    LIBS += -exported_symbols_list $$PWD/vamp-aubio-plugins/vamp-plugin.list
}
!win* {
    QMAKE_POST_LINK += cp vamp-aubio-plugins/vamp-aubio.* out/
}

SOURCES += \
    aubio/src/cvec.c \
    aubio/src/fmat.c \
    aubio/src/fvec.c \
    aubio/src/lvec.c \
    aubio/src/mathutils.c \
    aubio/src/musicutils.c \
    aubio/src/vecutils.c \
    aubio/src/notes/notes.c \
    aubio/src/onset/onset.c \
    aubio/src/onset/peakpicker.c \
    aubio/src/pitch/pitch.c \
    aubio/src/pitch/pitchfcomb.c \
    aubio/src/pitch/pitchmcomb.c \
    aubio/src/pitch/pitchschmitt.c \
    aubio/src/pitch/pitchspecacf.c \
    aubio/src/pitch/pitchyin.c \
    aubio/src/pitch/pitchyinfast.c \
    aubio/src/pitch/pitchyinfft.c \
    aubio/src/spectral/awhitening.c \
    aubio/src/spectral/dct.c \
    aubio/src/spectral/dct_ooura.c \
    aubio/src/spectral/dct_plain.c \
    aubio/src/spectral/fft.c \
    aubio/src/spectral/filterbank.c \
    aubio/src/spectral/filterbank_mel.c \
    aubio/src/spectral/mfcc.c \
    aubio/src/spectral/ooura_fft8g.c \
    aubio/src/spectral/phasevoc.c \
    aubio/src/spectral/specdesc.c \
    aubio/src/spectral/statistics.c \
    aubio/src/spectral/tss.c \
    aubio/src/tempo/beattracking.c \
    aubio/src/temporal/a_weighting.c \
    aubio/src/temporal/biquad.c \
    aubio/src/temporal/c_weighting.c \
    aubio/src/temporal/filter.c \
    aubio/src/temporal/resampler.c \
    aubio/src/tempo/tempo.c \
    aubio/src/utils/hist.c \
    aubio/src/utils/log.c \
    aubio/src/utils/parameter.c \
    aubio/src/utils/scale.c \
    aubio-link/MelEnergyPlugin.cpp \
    aubio-link/MfccPlugin.cpp \
    aubio-link/NotesPlugin.cpp \
    aubio-link/OnsetPlugin.cpp \
    aubio-link/PitchPlugin.cpp \
    aubio-link/SilencePlugin.cpp \
    aubio-link/SpecDescPlugin.cpp \
    aubio-link/TempoPlugin.cpp \
    vamp-aubio-plugins/plugins/Types.cpp \
    vamp-aubio-plugins/libmain.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

