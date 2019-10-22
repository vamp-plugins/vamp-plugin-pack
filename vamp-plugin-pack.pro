
TEMPLATE = subdirs

SUBDIRS += \
        sub_sdk \
        sub_match \
        sub_tuning_difference \
        sub_pyin \
        sub_nnls_chroma \
        sub_qm_vamp_plugins \
        sub_azi

sub_sdk.file = vamp-plugin-sdk.pro
sub_match.file = match-vamp.pro
sub_pyin.file = pyin.pro
sub_tuning_difference.file = tuning-difference.pro
sub_nnls_chroma.file = nnls-chroma.pro
sub_qm_vamp_plugins.file = qm-vamp-plugins.pro
sub_azi.file = azi.pro

repoint.target = $$PWD/.repoint.point
repoint.depends = $$PWD/repoint-project.json $$PWD/repoint-lock.json
repoint.commands = $$PWD/repoint install --directory $$PWD

QMAKE_EXTRA_TARGETS += repoint
PRE_TARGETDEPS += $$repoint.target

CONFIG += ordered
