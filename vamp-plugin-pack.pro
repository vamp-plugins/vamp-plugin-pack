
TEMPLATE = subdirs

SUBDIRS += \
        sub_sdk \
        sub_match \
        sub_tuning_difference \
        sub_pyin \
        sub_nnls_chroma \
        sub_qm_vamp_plugins \
        sub_azi \
        sub_aubio \
        sub_silvet \
        sub_tipic \
        sub_segmentino \
        sub_examples \
        sub_ua \
        sub_bbc \
        sub_cq \
        sub_cepstral_pitchtracker

sub_sdk.file = vamp-plugin-sdk.pro
sub_match.file = match-vamp.pro
sub_pyin.file = pyin.pro
sub_tuning_difference.file = tuning-difference.pro
sub_nnls_chroma.file = nnls-chroma.pro
sub_qm_vamp_plugins.file = qm-vamp-plugins.pro
sub_azi.file = azi.pro
sub_aubio.file = vamp-aubio-plugins.pro
sub_silvet.file = silvet.pro
sub_tipic.file = tipic.pro
sub_segmentino.file = segmentino.pro
sub_examples.file = vamp-example-plugins.pro
sub_ua.file = ua-vamp-plugins.pro
sub_bbc.file = bbc-vamp-plugins.pro
sub_cq.file = constant-q-cpp.pro
sub_cepstral_pitchtracker.file = cepstral-pitchtracker.pro

repoint.target = $$PWD/.repoint.point
repoint.depends = $$PWD/repoint-project.json $$PWD/repoint-lock.json
repoint.commands = $$PWD/repoint install --directory $$PWD

QMAKE_EXTRA_TARGETS += repoint
PRE_TARGETDEPS += $$repoint.target

CONFIG += ordered
