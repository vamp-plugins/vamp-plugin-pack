
TEMPLATE = lib

include(plugin.pri)

TARGET = out/mvamp

OBJECTS_DIR = marsyas/src/mvamp/o

INCLUDEPATH += $$PWD/marsyas-link $$PWD/marsyas/src $$PWD/marsyas/src/marsyas/marsystems $$PWD/marsyas/src/otherlibs/libsvm $$PWD/marsyas/src/otherlibs/liblinear

win32-msvc* {
    DEFINES += MARSYAS_WIN32
}
win32-g++* {
    DEFINES += MARSYAS_WIN32
}

!win* {
    QMAKE_POST_LINK += && \
        cp marsyas/src/mvamp/mvamp.n3 out/ && \
        cp marsyas/README out/mvamp_README.txt && \
        cp marsyas/COPYING out/mvamp_COPYING.txt && \
        cat marsyas/src/mvamp/mvamp.cat | sed 's/Beat/Tempo/' > out/mvamp.cat && \
        echo "vamp:mvamp:zerocrossing::Low Level Features" >> out/mvamp.cat
}

SOURCES += \
    marsyas/src/mvamp/ZeroCrossing.cpp \
    marsyas/src/mvamp/MarsyasBExtractZeroCrossings.cpp \
    marsyas/src/mvamp/MarsyasBExtractCentroid.cpp \
    marsyas/src/mvamp/MarsyasBExtractLPCC.cpp \
    marsyas/src/mvamp/MarsyasBExtractLSP.cpp \
    marsyas/src/mvamp/MarsyasBExtractMFCC.cpp \
    marsyas/src/mvamp/MarsyasBExtractRolloff.cpp \
    marsyas/src/mvamp/MarsyasBExtractSCF.cpp \
    marsyas/src/mvamp/MarsyasBExtractSFM.cpp \
    marsyas/src/mvamp/MarsyasIBT.cpp \
    marsyas/src/mvamp/plugins.cpp \
    vamp-plugin-sdk/src/vamp-sdk/PluginAdapter.cpp \
    vamp-plugin-sdk/src/vamp-sdk/RealTime.cpp

SOURCES += \
    marsyas/src/marsyas/sched/Scheduler.cpp \
    marsyas/src/marsyas/sched/Repeat.cpp \
    marsyas/src/marsyas/sched/TmTime.cpp \
    marsyas/src/marsyas/sched/TmVirtualTime.cpp \
    marsyas/src/marsyas/sched/TmTimer.cpp \
    marsyas/src/marsyas/sched/TmParam.cpp \
    marsyas/src/marsyas/sched/TmTimerManager.cpp \
    marsyas/src/marsyas/sched/TmControlValue.cpp \
    marsyas/src/marsyas/sched/TmRealTime.cpp \
    marsyas/src/marsyas/sched/EvEvent.cpp \
    marsyas/src/marsyas/sched/EvValUpd.cpp \
    marsyas/src/marsyas/system/MarControl.cpp \
    marsyas/src/marsyas/system/MarControlValue.cpp \
    marsyas/src/marsyas/system/MarControlManager.cpp \
    marsyas/src/marsyas/system/MarSystem.cpp \
    marsyas/src/marsyas/system/MarSystemManager.cpp

SOURCES += \
    marsyas/src/marsyas/realvec.cpp \
    marsyas/src/marsyas/FileName.cpp \
    marsyas/src/marsyas/MrsLog.cpp \
    marsyas/src/marsyas/Collection.cpp \
    marsyas/src/marsyas/CommandLineOptions.cpp \
    marsyas/src/marsyas/Conversions.cpp \
    marsyas/src/marsyas/WekaData.cpp \
    marsyas/src/marsyas/peakView.cpp \
    marsyas/src/marsyas/TimeLine.cpp \
    marsyas/src/marsyas/fft.cpp \
    marsyas/src/marsyas/NumericLib.cpp \
    marsyas/src/marsyas/QGMMModel.cpp \
    marsyas/src/marsyas/basis.cpp \
    marsyas/src/marsyas/vmblock.cpp \
    marsyas/src/marsyas/lu.cpp \
    marsyas/src/marsyas/expr/Expr.cpp \
    marsyas/src/marsyas/expr/ExNode.cpp \
    marsyas/src/marsyas/expr/ExParser.cpp \
    marsyas/src/marsyas/expr/ExScanner.cpp \
    marsyas/src/marsyas/expr/ExCommon.cpp \
    marsyas/src/marsyas/expr/ExVal.cpp \
    marsyas/src/marsyas/expr/ExSymTbl.cpp \
    marsyas/src/otherlibs/libsvm/svm.cpp \
    marsyas/src/otherlibs/liblinear/linear.cpp \
    marsyas/src/otherlibs/liblinear/tron.cpp \
    marsyas/src/otherlibs/liblinear/blas/dnrm2.c \
    marsyas/src/otherlibs/liblinear/blas/ddot.c \
    marsyas/src/otherlibs/liblinear/blas/daxpy.c \
    marsyas/src/otherlibs/liblinear/blas/dscal.c

# All the systems included into MarSystemManager must be compiled in,
# otherwise we'll have undefined symbols for their dtors at least even
# if they aren't used by any plugin:

SOURCES += \
    marsyas/src/marsyas/marsystems/AbsMax.cpp \
    marsyas/src/marsyas/marsystems/AbsSoundFileSink.cpp \
    marsyas/src/marsyas/marsystems/AbsSoundFileSource2.cpp \
    marsyas/src/marsyas/marsystems/AbsSoundFileSource.cpp \
    marsyas/src/marsyas/marsystems/AccentFilterBank.cpp \
    marsyas/src/marsyas/marsystems/Accumulator.cpp \
    marsyas/src/marsyas/marsystems/AdditiveOsc.cpp \
    marsyas/src/marsyas/marsystems/ADRess.cpp \
    marsyas/src/marsyas/marsystems/ADRessSpectrum.cpp \
    marsyas/src/marsyas/marsystems/ADRessStereoSpectrum.cpp \
    marsyas/src/marsyas/marsystems/ADSR.cpp \
    marsyas/src/marsyas/marsystems/AimBoxes.cpp \
    marsyas/src/marsyas/marsystems/AimGammatone.cpp \
    marsyas/src/marsyas/marsystems/AimHCL2.cpp \
    marsyas/src/marsyas/marsystems/AimHCL.cpp \
    marsyas/src/marsyas/marsystems/AimLocalMax.cpp \
    marsyas/src/marsyas/marsystems/AimPZFC2.cpp \
    marsyas/src/marsyas/marsystems/AimPZFC.cpp \
    marsyas/src/marsyas/marsystems/AimSAI.cpp \
    marsyas/src/marsyas/marsystems/AimSSI.cpp \
    marsyas/src/marsyas/marsystems/AimVQ.cpp \
    marsyas/src/marsyas/marsystems/AliasingOsc.cpp \
    marsyas/src/marsyas/marsystems/AMDF.cpp \
    marsyas/src/marsyas/marsystems/ANN_node.cpp \
    marsyas/src/marsyas/marsystems/Annotator.cpp \
    marsyas/src/marsyas/marsystems/APDelayOsc.cpp \
    marsyas/src/marsyas/marsystems/ArffFileSink.cpp \
    marsyas/src/marsyas/marsystems/AubioYin.cpp \
    marsyas/src/marsyas/marsystems/AuFileSink.cpp \
    marsyas/src/marsyas/marsystems/AuFileSource.cpp \
    marsyas/src/marsyas/marsystems/AutoCorrelation.cpp \
    marsyas/src/marsyas/marsystems/AutoCorrelationFFT.cpp \
    marsyas/src/marsyas/marsystems/AveragingPattern.cpp \
    marsyas/src/marsyas/marsystems/BaseAudioSink.cpp \
    marsyas/src/marsyas/marsystems/BeatAgent.cpp \
    marsyas/src/marsyas/marsystems/BeatHistoFeatures.cpp \
    marsyas/src/marsyas/marsystems/BeatHistogram.cpp \
    marsyas/src/marsyas/marsystems/BeatHistogramFromPeaks.cpp \
    marsyas/src/marsyas/marsystems/BeatPhase.cpp \
    marsyas/src/marsyas/marsystems/BeatReferee.cpp \
    marsyas/src/marsyas/marsystems/BeatTimesSink.cpp \
    marsyas/src/marsyas/marsystems/BICchangeDetector.cpp \
    marsyas/src/marsyas/marsystems/Biquad.cpp \
    marsyas/src/marsyas/marsystems/BlitOsc.cpp \
    marsyas/src/marsyas/marsystems/CARFAC_coeffs.cpp \
    marsyas/src/marsyas/marsystems/CARFAC.cpp \
    marsyas/src/marsyas/marsystems/Cartesian2Polar.cpp \
    marsyas/src/marsyas/marsystems/Cascade.cpp \
    marsyas/src/marsyas/marsystems/Centroid.cpp \
    marsyas/src/marsyas/marsystems/Chroma.cpp \
    marsyas/src/marsyas/marsystems/ChromaFilter.cpp \
    marsyas/src/marsyas/marsystems/ChromaScale.cpp \
    marsyas/src/marsyas/marsystems/ClassificationReport.cpp \
    marsyas/src/marsyas/marsystems/ClassOutputSink.cpp \
    marsyas/src/marsyas/marsystems/Clip.cpp \
    marsyas/src/marsyas/marsystems/CollectionFileSource.cpp \
    marsyas/src/marsyas/marsystems/Combinator.cpp \
    marsyas/src/marsyas/marsystems/CompExp.cpp \
    marsyas/src/marsyas/marsystems/Compressor.cpp \
    marsyas/src/marsyas/marsystems/Confidence.cpp \
    marsyas/src/marsyas/marsystems/ConstQFiltering.cpp \
    marsyas/src/marsyas/marsystems/CrossCorrelation.cpp \
    marsyas/src/marsyas/marsystems/CsvFileSource.cpp \
    marsyas/src/marsyas/marsystems/CsvSink.cpp \
    marsyas/src/marsyas/marsystems/Daub4.cpp \
    marsyas/src/marsyas/marsystems/DCSource.cpp \
    marsyas/src/marsyas/marsystems/Deinterleave.cpp \
    marsyas/src/marsyas/marsystems/DeInterleaveSizecontrol.cpp \
    marsyas/src/marsyas/marsystems/Delay.cpp \
    marsyas/src/marsyas/marsystems/DelaySamples.cpp \
    marsyas/src/marsyas/marsystems/Delta.cpp \
    marsyas/src/marsyas/marsystems/DeltaFirstOrderRegression.cpp \
    marsyas/src/marsyas/marsystems/Differentiator.cpp \
    marsyas/src/marsyas/marsystems/DownSampler.cpp \
    marsyas/src/marsyas/marsystems/DPWOsc.cpp \
    marsyas/src/marsyas/marsystems/DTW.cpp \
    marsyas/src/marsyas/marsystems/DTWWD.cpp \
    marsyas/src/marsyas/marsystems/Energy.cpp \
    marsyas/src/marsyas/marsystems/EnhADRess.cpp \
    marsyas/src/marsyas/marsystems/EnhADRessStereoSpectrum.cpp \
    marsyas/src/marsyas/marsystems/Envelope.cpp \
    marsyas/src/marsyas/marsystems/ERB.cpp \
    marsyas/src/marsyas/marsystems/Esitar.cpp \
    marsyas/src/marsyas/marsystems/F0Analysis.cpp \
    marsyas/src/marsyas/marsystems/Fanin.cpp \
    marsyas/src/marsyas/marsystems/Fanout.cpp \
    marsyas/src/marsyas/marsystems/FanOutIn.cpp \
    marsyas/src/marsyas/marsystems/Filter.cpp \
    marsyas/src/marsyas/marsystems/FlowCutSource.cpp \
    marsyas/src/marsyas/marsystems/FlowThru.cpp \
    marsyas/src/marsyas/marsystems/FlowToControl.cpp \
    marsyas/src/marsyas/marsystems/Flux.cpp \
    marsyas/src/marsyas/marsystems/FM.cpp \
    marsyas/src/marsyas/marsystems/FMeasure.cpp \
    marsyas/src/marsyas/marsystems/FullWaveRectifier.cpp \
    marsyas/src/marsyas/marsystems/Gain.cpp \
    marsyas/src/marsyas/marsystems/GaussianClassifier.cpp \
    marsyas/src/marsyas/marsystems/GMMClassifier.cpp \
    marsyas/src/marsyas/marsystems/HalfWaveRectifier.cpp \
    marsyas/src/marsyas/marsystems/HarmonicEnhancer.cpp \
    marsyas/src/marsyas/marsystems/HarmonicStrength.cpp \
    marsyas/src/marsyas/marsystems/Histogram.cpp \
    marsyas/src/marsyas/marsystems/HWPS.cpp \
    marsyas/src/marsyas/marsystems/Inject.cpp \
    marsyas/src/marsyas/marsystems/InvSpectrum.cpp \
    marsyas/src/marsyas/marsystems/KNNClassifier.cpp \
    marsyas/src/marsyas/marsystems/Krumhansl_key_finder.cpp \
    marsyas/src/marsyas/marsystems/Kurtosis.cpp \
    marsyas/src/marsyas/marsystems/Limiter.cpp \
    marsyas/src/marsyas/marsystems/LPCC.cpp \
    marsyas/src/marsyas/marsystems/LPC.cpp \
    marsyas/src/marsyas/marsystems/LSP.cpp \
    marsyas/src/marsyas/marsystems/LyonPassiveEar.cpp \
    marsyas/src/marsyas/marsystems/Map.cpp \
    marsyas/src/marsyas/marsystems/MarFileSink.cpp \
    marsyas/src/marsyas/marsystems/MarSystemTemplateAdvanced.cpp \
    marsyas/src/marsyas/marsystems/MarSystemTemplateBasic.cpp \
    marsyas/src/marsyas/marsystems/MarSystemTemplateMedium.cpp \
    marsyas/src/marsyas/marsystems/MatchBassModel.cpp \
    marsyas/src/marsyas/marsystems/MathPower.cpp \
    marsyas/src/marsyas/marsystems/MaxArgMax.cpp \
    marsyas/src/marsyas/marsystems/MaxMin.cpp \
    marsyas/src/marsyas/marsystems/McAulayQuatieri.cpp \
    marsyas/src/marsyas/marsystems/MeanAbsoluteDeviation.cpp \
    marsyas/src/marsyas/marsystems/Mean.cpp \
    marsyas/src/marsyas/marsystems/MeddisHairCell.cpp \
    marsyas/src/marsyas/marsystems/Median.cpp \
    marsyas/src/marsyas/marsystems/MedianFilter.cpp \
    marsyas/src/marsyas/marsystems/Memory.cpp \
    marsyas/src/marsyas/marsystems/MemorySource.cpp \
    marsyas/src/marsyas/marsystems/Metric2.cpp \
    marsyas/src/marsyas/marsystems/Metric.cpp \
    marsyas/src/marsyas/marsystems/MFCC.cpp \
    marsyas/src/marsyas/marsystems/MidiFileSynthSource.cpp \
    marsyas/src/marsyas/marsystems/MidiInput.cpp \
    marsyas/src/marsyas/marsystems/MidiOutput.cpp \
    marsyas/src/marsyas/marsystems/MinArgMin.cpp \
    marsyas/src/marsyas/marsystems/MixToMono.cpp \
    marsyas/src/marsyas/marsystems/Mono2Stereo.cpp \
    marsyas/src/marsyas/marsystems/Negative.cpp \
    marsyas/src/marsyas/marsystems/NoiseGate.cpp \
    marsyas/src/marsyas/marsystems/NoiseSource.cpp \
    marsyas/src/marsyas/marsystems/NormalizeAbs.cpp \
    marsyas/src/marsyas/marsystems/Normalize.cpp \
    marsyas/src/marsyas/marsystems/Norm.cpp \
    marsyas/src/marsyas/marsystems/NormCut.cpp \
    marsyas/src/marsyas/marsystems/NormMatrix.cpp \
    marsyas/src/marsyas/marsystems/NormMaxMin.cpp \
    marsyas/src/marsyas/marsystems/OnePole.cpp \
    marsyas/src/marsyas/marsystems/OneRClassifier.cpp \
    marsyas/src/marsyas/marsystems/OnsetTimes.cpp \
    marsyas/src/marsyas/marsystems/OrcaSnip.cpp \
    marsyas/src/marsyas/marsystems/OverlapAdd.cpp \
    marsyas/src/marsyas/marsystems/Panorama.cpp \
    marsyas/src/marsyas/marsystems/Parallel.cpp \
    marsyas/src/marsyas/marsystems/ParallelMatrixWeight.cpp \
    marsyas/src/marsyas/marsystems/PatchMatrix.cpp \
    marsyas/src/marsyas/marsystems/PCA.cpp \
    marsyas/src/marsyas/marsystems/Peak2Rms.cpp \
    marsyas/src/marsyas/marsystems/PeakClusterSelect.cpp \
    marsyas/src/marsyas/marsystems/PeakConvert2.cpp \
    marsyas/src/marsyas/marsystems/PeakConvert.cpp \
    marsyas/src/marsyas/marsystems/PeakDistanceHorizontality.cpp \
    marsyas/src/marsyas/marsystems/PeakEnhancer.cpp \
    marsyas/src/marsyas/marsystems/PeakerAdaptive.cpp \
    marsyas/src/marsyas/marsystems/Peaker.cpp \
    marsyas/src/marsyas/marsystems/PeakerOnset.cpp \
    marsyas/src/marsyas/marsystems/PeakFeatureSelect.cpp \
    marsyas/src/marsyas/marsystems/PeakInObservation.cpp \
    marsyas/src/marsyas/marsystems/PeakLabeler.cpp \
    marsyas/src/marsyas/marsystems/PeakMask.cpp \
    marsyas/src/marsyas/marsystems/PeakPeriods2BPM.cpp \
    marsyas/src/marsyas/marsystems/PeakRatio.cpp \
    marsyas/src/marsyas/marsystems/PeakResidual.cpp \
    marsyas/src/marsyas/marsystems/PeakSynthFFT.cpp \
    marsyas/src/marsyas/marsystems/PeakSynthOscBank.cpp \
    marsyas/src/marsyas/marsystems/PeakSynthOsc.cpp \
    marsyas/src/marsyas/marsystems/PeakViewMerge.cpp \
    marsyas/src/marsyas/marsystems/PeakViewSink.cpp \
    marsyas/src/marsyas/marsystems/PeakViewSource.cpp \
    marsyas/src/marsyas/marsystems/PhaseLock.cpp \
    marsyas/src/marsyas/marsystems/PhiSEMFilter.cpp \
    marsyas/src/marsyas/marsystems/PhiSEMSource.cpp \
    marsyas/src/marsyas/marsystems/Pitch2Chroma.cpp \
    marsyas/src/marsyas/marsystems/PitchDiff.cpp \
    marsyas/src/marsyas/marsystems/PlotSink.cpp \
    marsyas/src/marsyas/marsystems/Plucked.cpp \
    marsyas/src/marsyas/marsystems/Polar2Cartesian.cpp \
    marsyas/src/marsyas/marsystems/Power.cpp \
    marsyas/src/marsyas/marsystems/PowerSpectrum.cpp \
    marsyas/src/marsyas/marsystems/PowerToAverageRatio.cpp \
    marsyas/src/marsyas/marsystems/Product.cpp \
    marsyas/src/marsyas/marsystems/PvConvert.cpp \
    marsyas/src/marsyas/marsystems/PvConvolve.cpp \
    marsyas/src/marsyas/marsystems/PvFold.cpp \
    marsyas/src/marsyas/marsystems/PvMultiResolution.cpp \
    marsyas/src/marsyas/marsystems/PvOscBank.cpp \
    marsyas/src/marsyas/marsystems/PvOverlapadd.cpp \
    marsyas/src/marsyas/marsystems/PvUnconvert.cpp \
    marsyas/src/marsyas/marsystems/PWMSource.cpp \
    marsyas/src/marsyas/marsystems/RadioDrumInput.cpp \
    marsyas/src/marsyas/marsystems/Ratio.cpp \
    marsyas/src/marsyas/marsystems/RawFileSource.cpp \
    marsyas/src/marsyas/marsystems/RBF.cpp \
    marsyas/src/marsyas/marsystems/RealvecSink.cpp \
    marsyas/src/marsyas/marsystems/RealvecSource.cpp \
    marsyas/src/marsyas/marsystems/Reassign.cpp \
    marsyas/src/marsyas/marsystems/Reciprocal.cpp \
    marsyas/src/marsyas/marsystems/RemoveObservations.cpp \
    marsyas/src/marsyas/marsystems/ResampleBezier.cpp \
    marsyas/src/marsyas/marsystems/Resample.cpp \
    marsyas/src/marsyas/marsystems/ResampleLinear.cpp \
    marsyas/src/marsyas/marsystems/ResampleNearestNeighbour.cpp \
    marsyas/src/marsyas/marsystems/ResampleSinc.cpp \
    marsyas/src/marsyas/marsystems/Reverse.cpp \
    marsyas/src/marsyas/marsystems/Rms.cpp \
    marsyas/src/marsyas/marsystems/Rolloff.cpp \
    marsyas/src/marsyas/marsystems/RunningAutocorrelation.cpp \
    marsyas/src/marsyas/marsystems/RunningStatistics.cpp \
    marsyas/src/marsyas/marsystems/SCF.cpp \
    marsyas/src/marsyas/marsystems/Selector.cpp \
    marsyas/src/marsyas/marsystems/SelfSimilarityMatrix.cpp \
    marsyas/src/marsyas/marsystems/SeneffEar.cpp \
    marsyas/src/marsyas/marsystems/Series.cpp \
    marsyas/src/marsyas/marsystems/SFM.cpp \
    marsyas/src/marsyas/marsystems/Shifter.cpp \
    marsyas/src/marsyas/marsystems/ShiftInput.cpp \
    marsyas/src/marsyas/marsystems/ShiftOutput.cpp \
    marsyas/src/marsyas/marsystems/Shredder.cpp \
    marsyas/src/marsyas/marsystems/Sidechain.cpp \
    marsyas/src/marsyas/marsystems/Signum.cpp \
    marsyas/src/marsyas/marsystems/SilenceRemove.cpp \
    marsyas/src/marsyas/marsystems/SimilarityMatrix.cpp \
    marsyas/src/marsyas/marsystems/SimulMaskingFft.cpp \
    marsyas/src/marsyas/marsystems/SineSource.cpp \
    marsyas/src/marsyas/marsystems/Skewness.cpp \
    marsyas/src/marsyas/marsystems/SliceDelta.cpp \
    marsyas/src/marsyas/marsystems/SliceShuffle.cpp \
    marsyas/src/marsyas/marsystems/SMO.cpp \
    marsyas/src/marsyas/marsystems/SNR.cpp \
    marsyas/src/marsyas/marsystems/SOM.cpp \
    marsyas/src/marsyas/marsystems/SoundFileSink.cpp \
    marsyas/src/marsyas/marsystems/SoundFileSource2.cpp \
    marsyas/src/marsyas/marsystems/SoundFileSource.cpp \
    marsyas/src/marsyas/marsystems/SoundFileSourceHopper.cpp \
    marsyas/src/marsyas/marsystems/SpectralCentroidBandNorm.cpp \
    marsyas/src/marsyas/marsystems/SpectralFlatnessAllBands.cpp \
    marsyas/src/marsyas/marsystems/SpectralSNR.cpp \
    marsyas/src/marsyas/marsystems/SpectralTransformations.cpp \
    marsyas/src/marsyas/marsystems/Spectrum2ACMChroma.cpp \
    marsyas/src/marsyas/marsystems/Spectrum2Chroma.cpp \
    marsyas/src/marsyas/marsystems/Spectrum2Mel.cpp \
    marsyas/src/marsyas/marsystems/Spectrum.cpp \
    marsyas/src/marsyas/marsystems/Square.cpp \
    marsyas/src/marsyas/marsystems/StandardDeviation.cpp \
    marsyas/src/marsyas/marsystems/StereoSpectrum.cpp \
    marsyas/src/marsyas/marsystems/StereoSpectrumFeatures.cpp \
    marsyas/src/marsyas/marsystems/StereoSpectrumSources.cpp \
    marsyas/src/marsyas/marsystems/StretchLinear.cpp \
    marsyas/src/marsyas/marsystems/Subtract.cpp \
    marsyas/src/marsyas/marsystems/SubtractMean.cpp \
    marsyas/src/marsyas/marsystems/Sum.cpp \
    marsyas/src/marsyas/marsystems/SVFilter.cpp \
    marsyas/src/marsyas/marsystems/SVMClassifier.cpp \
    marsyas/src/marsyas/marsystems/TempoHypotheses.cpp \
    marsyas/src/marsyas/marsystems/Threshold.cpp \
    marsyas/src/marsyas/marsystems/TimeFreqPeakConnectivity.cpp \
    marsyas/src/marsyas/marsystems/TimelineLabeler.cpp \
    marsyas/src/marsyas/marsystems/Timer.cpp \
    marsyas/src/marsyas/marsystems/TimeStretch.cpp \
    marsyas/src/marsyas/marsystems/Transposer.cpp \
    marsyas/src/marsyas/marsystems/TriangularFilterBank.cpp \
    marsyas/src/marsyas/marsystems/Unfold.cpp \
    marsyas/src/marsyas/marsystems/UpdatingBassModel.cpp \
    marsyas/src/marsyas/marsystems/Upsample.cpp \
    marsyas/src/marsyas/marsystems/Vibrato.cpp \
    marsyas/src/marsyas/marsystems/ViconFileSource.cpp \
    marsyas/src/marsyas/marsystems/WaveguideOsc.cpp \
    marsyas/src/marsyas/marsystems/WaveletBands.cpp \
    marsyas/src/marsyas/marsystems/WaveletPyramid.cpp \
    marsyas/src/marsyas/marsystems/WaveletStep.cpp \
    marsyas/src/marsyas/marsystems/WavFileSink.cpp \
    marsyas/src/marsyas/marsystems/WavFileSource2.cpp \
    marsyas/src/marsyas/marsystems/WavFileSource.cpp \
    marsyas/src/marsyas/marsystems/WekaSink.cpp \
    marsyas/src/marsyas/marsystems/WekaSource.cpp \
    marsyas/src/marsyas/marsystems/WHaSp.cpp \
    marsyas/src/marsyas/marsystems/Whitening.cpp \
    marsyas/src/marsyas/marsystems/Windowing.cpp \
    marsyas/src/marsyas/marsystems/Yin.cpp \
    marsyas/src/marsyas/marsystems/ZeroCrossings.cpp \
    marsyas/src/marsyas/marsystems/ZeroRClassifier.cpp
    
