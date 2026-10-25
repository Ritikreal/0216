import numpy as np

from al.audio import detection_threshold, rms_level


def test_rms_level_is_zero_for_empty_audio():
    assert rms_level(np.array([], dtype=np.float32)) == 0.0


def test_rms_level_measures_known_signal():
    signal = np.array([0.0, 1.0, 0.0, -1.0], dtype=np.float32)
    assert np.isclose(rms_level(signal), np.sqrt(0.5))


def test_detection_threshold_uses_median_noise_and_floor():
    # The outlier should not dominate the median-based room-noise estimate.
    result = detection_threshold([0.001, 0.001, 0.001, 0.5], 0.00015, 1.5)
    assert np.isclose(result, 0.0015)


def test_detection_threshold_never_drops_below_configured_floor():
    assert detection_threshold([0.00001, 0.00002], 0.00015, 1.5) == 0.00015
