
TEMPLATE = subdirs

SUBDIRS += \
        sub_plugins \
        sub_get_version \
        sub_installer

sub_plugins.file = plugins.pro
sub_get_version.file = get-version.pro
sub_installer.file = installer.pro

repoint.target = $$PWD/.repoint.point
repoint.depends = $$PWD/repoint-project.json $$PWD/repoint-lock.json
repoint.commands = $$PWD/repoint install --directory $$PWD

QMAKE_EXTRA_TARGETS += repoint
PRE_TARGETDEPS += $$repoint.target

CONFIG += ordered
