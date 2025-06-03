import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'face_detection.dart';

/// Type of AR effect
enum AREffectType {
  /// 2D mask overlay
  mask2D,
  
  /// 3D mask overlay
  mask3D,
  
  /// Beauty makeup effect
  beauty,
  
  /// Face distortion effect
  distortion,
  
  /// Background replacement
  background,
  
  /// 3D object placement
  object3D,
  
  /// Custom shader-based effect
  customShader
}

/// Abstract class representing an AR effect
abstract class AREffect {
  /// Unique identifier for the effect
  final String id;
  
  /// Display name for the effect
  final String name;
  
  /// Type of the effect
  final AREffectType type;
  
  /// Intensity of the effect (0.0-1.0)
  final double intensity;
  
  /// Optional thumbnail image
  final Uint8List? thumbnail;
  
  /// Whether the effect requires face detection
  final bool requiresFaceDetection;

  /// Creates an AREffect instance
  AREffect({
    required this.id,
    required this.name,
    required this.type,
    this.intensity = 1.0,
    this.thumbnail,
    this.requiresFaceDetection = false,
  });

  /// Apply the effect to detected faces
  void applyToFaces(List<DetectedFace> faces);
  
  /// Creates a copy with updated fields
  AREffect copyWith({double? intensity});
}

/// A 2D mask effect that overlays images on faces
class MaskEffect extends AREffect {
  /// Path to the mask image asset
  final String maskPath;
  
  /// Whether to track face movements
  final bool trackFace;

  /// Creates a MaskEffect instance
  MaskEffect({
    required String id,
    required String name,
    required this.maskPath,
    this.trackFace = true,
    double intensity = 1.0,
    Uint8List? thumbnail,
  }) : super(
          id: id,
          name: name,
          type: AREffectType.mask2D,
          intensity: intensity,
          thumbnail: thumbnail,
          requiresFaceDetection: true,
        );

  @override
  void applyToFaces(List<DetectedFace> faces) {
    // Implementation will be handled by native code
  }

  @override
  AREffect copyWith({double? intensity}) {
    return MaskEffect(
      id: id,
      name: name,
      maskPath: maskPath,
      trackFace: trackFace,
      intensity: intensity ?? this.intensity,
      thumbnail: thumbnail,
    );
  }
}

/// A 3D mask effect that overlays 3D models on faces
class Mask3DEffect extends AREffect {
  /// Path to the 3D model asset
  final String modelPath;

  /// Creates a Mask3DEffect instance
  Mask3DEffect({
    required String id,
    required String name,
    required this.modelPath,
    double intensity = 1.0,
    Uint8List? thumbnail,
  }) : super(
          id: id,
          name: name,
          type: AREffectType.mask3D,
          intensity: intensity,
          thumbnail: thumbnail,
          requiresFaceDetection: true,
        );

  @override
  void applyToFaces(List<DetectedFace> faces) {
    // Implementation will be handled by native code
  }

  @override
  AREffect copyWith({double? intensity}) {
    return Mask3DEffect(
      id: id,
      name: name,
      modelPath: modelPath,
      intensity: intensity ?? this.intensity,
      thumbnail: thumbnail,
    );
  }
}

/// A beauty effect that enhances facial features
class BeautyEffect extends AREffect {
  /// Smoothing level for skin
  final double smoothing;
  
  /// Whitening level for skin
  final double whitening;
  
  /// Eye enlargement factor
  final double eyeEnlarge;
  
  /// Face slimming factor
  final double faceSlim;

  /// Creates a BeautyEffect instance
  BeautyEffect({
    required String id,
    required String name,
    this.smoothing = 0.5,
    this.whitening = 0.3,
    this.eyeEnlarge = 0.0,
    this.faceSlim = 0.0,
    double intensity = 1.0,
    Uint8List? thumbnail,
  }) : super(
          id: id,
          name: name,
          type: AREffectType.beauty,
          intensity: intensity,
          thumbnail: thumbnail,
          requiresFaceDetection: true,
        );

  @override
  void applyToFaces(List<DetectedFace> faces) {
    // Implementation will be handled by native code
  }

  @override
  AREffect copyWith({double? intensity}) {
    return BeautyEffect(
      id: id,
      name: name,
      smoothing: smoothing,
      whitening: whitening,
      eyeEnlarge: eyeEnlarge,
      faceSlim: faceSlim,
      intensity: intensity ?? this.intensity,
      thumbnail: thumbnail,
    );
  }
}

/// A face distortion effect
class DistortionEffect extends AREffect {
  /// Type of distortion to apply
  final String distortionType;
  
  /// Parameters for the distortion
  final Map<String, dynamic> distortionParams;

  /// Creates a DistortionEffect instance
  DistortionEffect({
    required String id,
    required String name,
    required this.distortionType,
    this.distortionParams = const {},
    double intensity = 1.0,
    Uint8List? thumbnail,
  }) : super(
          id: id,
          name: name,
          type: AREffectType.distortion,
          intensity: intensity,
          thumbnail: thumbnail,
          requiresFaceDetection: true,
        );

  @override
  void applyToFaces(List<DetectedFace> faces) {
    // Implementation will be handled by native code
  }

  @override
  AREffect copyWith({double? intensity}) {
    return DistortionEffect(
      id: id,
      name: name,
      distortionType: distortionType,
      distortionParams: distortionParams,
      intensity: intensity ?? this.intensity,
      thumbnail: thumbnail,
    );
  }
}

/// A collection of preset AR effects available in the SDK
class PresetAREffects {
  /// Get a simple dog face mask effect
  static MaskEffect get dogMask => MaskEffect(
        id: 'ar_dog_mask',
        name: 'Dog',
        maskPath: 'assets/ar/dog_mask.png',
      );

  /// Get a cat face mask effect
  static MaskEffect get catMask => MaskEffect(
        id: 'ar_cat_mask',
        name: 'Cat',
        maskPath: 'assets/ar/cat_mask.png',
      );

  /// Get a basic beauty effect
  static BeautyEffect get beautyBasic => BeautyEffect(
        id: 'ar_beauty_basic',
        name: 'Beauty',
        smoothing: 0.5,
        whitening: 0.3,
      );

  /// Get a beauty effect with eye enlargement
  static BeautyEffect get beautyPlus => BeautyEffect(
        id: 'ar_beauty_plus',
        name: 'Beauty+',
        smoothing: 0.6,
        whitening: 0.4,
        eyeEnlarge: 0.3,
        faceSlim: 0.2,
      );

  /// Get a bulge face distortion effect
  static DistortionEffect get bulgeEffect => DistortionEffect(
        id: 'ar_bulge',
        name: 'Bulge',
        distortionType: 'bulge',
        distortionParams: {'radius': 0.5, 'amount': 0.5},
      );

  /// Get all available preset AR effects
  static List<AREffect> getAll() {
    return [
      dogMask,
      catMask,
      beautyBasic,
      beautyPlus,
      bulgeEffect,
    ];
  }
} 