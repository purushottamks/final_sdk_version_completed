import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'filter_type.dart';

/// Abstract class representing a filter that can be applied to camera preview/photos
abstract class Filter {
  /// Unique identifier for the filter
  final String id;
  
  /// Display name for the filter
  final String name;
  
  /// Type of the filter
  final FilterType type;
  
  /// Intensity of the filter effect (0.0 to 1.0)
  final double intensity;
  
  /// Optional thumbnail image for the filter (used in UI)
  final Uint8List? thumbnail;

  /// Creates a Filter instance
  Filter({
    required this.id,
    required this.name,
    required this.type,
    this.intensity = 1.0,
    this.thumbnail,
  });

  /// Apply the filter to the given image data
  Future<Uint8List> apply(Uint8List imageData, {int? width, int? height});
  
  /// Creates a copy of this filter with the given fields replaced
  Filter copyWith({double? intensity});
  
  /// Returns the shader code for GPU-accelerated filters
  String? getShaderCode() => null;
  
  /// Returns the path to a LUT file if this is a LUT-based filter
  String? getLutPath() => null;
  
  /// Returns the parameters for this filter
  Map<String, dynamic> getParameters() => {'intensity': intensity};
}

/// A basic filter implementation that uses a type and intensity
class BasicFilter extends Filter {
  /// Creates a BasicFilter instance
  BasicFilter({
    required String id,
    required String name,
    required FilterType type,
    double intensity = 1.0,
    Uint8List? thumbnail,
  }) : super(
          id: id,
          name: name,
          type: type,
          intensity: intensity,
          thumbnail: thumbnail,
        );

  @override
  Future<Uint8List> apply(Uint8List imageData, {int? width, int? height}) async {
    // This would be implemented by the platform-specific code
    // This is just a placeholder for the interface
    return imageData;
  }

  @override
  Filter copyWith({double? intensity}) {
    return BasicFilter(
      id: id,
      name: name,
      type: type,
      intensity: intensity ?? this.intensity,
      thumbnail: thumbnail,
    );
  }
}

/// A LUT-based filter that uses a 3D color lookup table
class LutFilter extends Filter {
  /// Path to the LUT file
  final String lutPath;

  /// Creates a LutFilter instance
  LutFilter({
    required String id,
    required String name,
    required this.lutPath,
    double intensity = 1.0,
    Uint8List? thumbnail,
  }) : super(
          id: id,
          name: name,
          type: FilterType.customLut,
          intensity: intensity,
          thumbnail: thumbnail,
        );

  @override
  Future<Uint8List> apply(Uint8List imageData, {int? width, int? height}) async {
    // This would be implemented by the platform-specific code
    // This is just a placeholder for the interface
    return imageData;
  }

  @override
  String? getLutPath() => lutPath;

  @override
  Filter copyWith({double? intensity}) {
    return LutFilter(
      id: id,
      name: name,
      lutPath: lutPath,
      intensity: intensity ?? this.intensity,
      thumbnail: thumbnail,
    );
  }
}

/// A shader-based filter that uses custom shader code
class ShaderFilter extends Filter {
  /// The shader code
  final String shaderCode;
  
  /// Additional parameters for the shader
  final Map<String, dynamic> shaderParams;

  /// Creates a ShaderFilter instance
  ShaderFilter({
    required String id,
    required String name,
    required this.shaderCode,
    this.shaderParams = const {},
    double intensity = 1.0,
    Uint8List? thumbnail,
  }) : super(
          id: id,
          name: name,
          type: FilterType.customShader,
          intensity: intensity,
          thumbnail: thumbnail,
        );

  @override
  Future<Uint8List> apply(Uint8List imageData, {int? width, int? height}) async {
    // This would be implemented by the platform-specific code
    // This is just a placeholder for the interface
    return imageData;
  }

  @override
  String? getShaderCode() => shaderCode;

  @override
  Map<String, dynamic> getParameters() {
    return {
      ...super.getParameters(),
      ...shaderParams,
    };
  }

  @override
  Filter copyWith({double? intensity}) {
    return ShaderFilter(
      id: id,
      name: name,
      shaderCode: shaderCode,
      shaderParams: shaderParams,
      intensity: intensity ?? this.intensity,
      thumbnail: thumbnail,
    );
  }
}