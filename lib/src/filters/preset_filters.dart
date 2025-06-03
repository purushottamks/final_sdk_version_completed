import 'dart:typed_data';
import 'filter.dart';
import 'filter_type.dart';

/// A collection of preset filters available in the SDK
class PresetFilters {
  /// No filter - passes the image through unchanged
  static BasicFilter get none => BasicFilter(
        id: 'filter_none',
        name: 'Original',
        type: FilterType.none,
      );

  /// Sepia tone filter
  static BasicFilter get sepia => BasicFilter(
        id: 'filter_sepia',
        name: 'Sepia',
        type: FilterType.sepia,
      );

  /// Black and white filter
  static BasicFilter get blackAndWhite => BasicFilter(
        id: 'filter_bw',
        name: 'B&W',
        type: FilterType.blackAndWhite,
      );

  /// Vintage photo filter
  static BasicFilter get vintage => BasicFilter(
        id: 'filter_vintage',
        name: 'Vintage',
        type: FilterType.vintage,
      );

  /// Vignette effect filter
  static BasicFilter get vignette => BasicFilter(
        id: 'filter_vignette',
        name: 'Vignette',
        type: FilterType.vignette,
      );

  /// Beauty filter for skin smoothing
  static BasicFilter get beauty => BasicFilter(
        id: 'filter_beauty',
        name: 'Beauty',
        type: FilterType.beauty,
      );

  /// Brightness adjustment filter
  static BasicFilter brightness({double intensity = 0.5}) => BasicFilter(
        id: 'filter_brightness',
        name: 'Brightness',
        type: FilterType.brightness,
        intensity: intensity,
      );

  /// Contrast adjustment filter
  static BasicFilter contrast({double intensity = 0.5}) => BasicFilter(
        id: 'filter_contrast',
        name: 'Contrast',
        type: FilterType.contrast,
        intensity: intensity,
      );

  /// Saturation adjustment filter
  static BasicFilter saturation({double intensity = 0.5}) => BasicFilter(
        id: 'filter_saturation',
        name: 'Saturation',
        type: FilterType.saturation,
        intensity: intensity,
      );

  /// Sharpness adjustment filter
  static BasicFilter sharpness({double intensity = 0.5}) => BasicFilter(
        id: 'filter_sharpness',
        name: 'Sharpness',
        type: FilterType.sharpness,
        intensity: intensity,
      );

  /// Blur effect filter
  static BasicFilter blur({double intensity = 0.5}) => BasicFilter(
        id: 'filter_blur',
        name: 'Blur',
        type: FilterType.blur,
        intensity: intensity,
      );

  /// Creates a custom LUT filter from a file
  static LutFilter customLut({
    required String name,
    required String lutPath,
    String? id,
    double intensity = 1.0,
    Uint8List? thumbnail,
  }) {
    return LutFilter(
      id: id ?? 'filter_lut_$name',
      name: name,
      lutPath: lutPath,
      intensity: intensity,
      thumbnail: thumbnail,
    );
  }

  /// Creates a custom shader filter
  static ShaderFilter customShader({
    required String name,
    required String shaderCode,
    String? id,
    Map<String, dynamic> params = const {},
    double intensity = 1.0,
    Uint8List? thumbnail,
  }) {
    return ShaderFilter(
      id: id ?? 'filter_shader_$name',
      name: name,
      shaderCode: shaderCode,
      shaderParams: params,
      intensity: intensity,
      thumbnail: thumbnail,
    );
  }

  /// Get all available preset filters
  static List<Filter> getAll() {
    return [
      none,
      sepia,
      blackAndWhite,
      vintage,
      vignette,
      beauty,
      brightness(),
      contrast(),
      saturation(),
      sharpness(),
      blur(),
    ];
  }
} 