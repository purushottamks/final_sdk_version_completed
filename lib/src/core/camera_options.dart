/// Enum representing available camera resolutions
enum CameraResolution {
  /// Low resolution (SD)
  low,
  
  /// Medium resolution (HD)
  medium,
  
  /// High resolution (Full HD)
  high,
  
  /// Ultra high resolution (4K)
  ultraHigh,
  
  /// Custom resolution
  custom
}

/// Enum representing camera lens direction
enum CameraLens {
  /// Front camera (selfie)
  front,
  
  /// Back camera
  back
}

/// Enum representing camera flash modes
enum FlashMode {
  /// Flash is always off
  off,
  
  /// Flash is always on
  on,
  
  /// Flash in auto mode
  auto,
  
  /// Torch mode (continuous light)
  torch
}

/// Class representing camera configuration options
class CameraOptions {
  /// The preferred camera resolution
  final CameraResolution resolution;
  
  /// The preferred camera lens
  final CameraLens lens;
  
  /// The preferred flash mode
  final FlashMode flashMode;
  
  /// The framerate for preview and recording (typically 30 or 60)
  final int fps;
  
  /// The zoom level (1.0 is no zoom)
  final double zoom;
  
  /// Whether to enable face detection
  final bool enableFaceDetection;
  
  /// Whether to record audio with video
  final bool enableAudio;
  
  /// Custom width (only used when resolution is custom)
  final int? customWidth;
  
  /// Custom height (only used when resolution is custom)
  final int? customHeight;

  /// Creates a CameraOptions instance
  const CameraOptions({
    this.resolution = CameraResolution.high,
    this.lens = CameraLens.back,
    this.flashMode = FlashMode.off,
    this.fps = 30,
    this.zoom = 1.0,
    this.enableFaceDetection = false,
    this.enableAudio = true,
    this.customWidth,
    this.customHeight,
  });

  /// Creates a copy with the given fields replaced
  CameraOptions copyWith({
    CameraResolution? resolution,
    CameraLens? lens,
    FlashMode? flashMode,
    int? fps,
    double? zoom,
    bool? enableFaceDetection,
    bool? enableAudio,
    int? customWidth,
    int? customHeight,
  }) {
    return CameraOptions(
      resolution: resolution ?? this.resolution,
      lens: lens ?? this.lens,
      flashMode: flashMode ?? this.flashMode,
      fps: fps ?? this.fps,
      zoom: zoom ?? this.zoom,
      enableFaceDetection: enableFaceDetection ?? this.enableFaceDetection,
      enableAudio: enableAudio ?? this.enableAudio,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
    );
  }

  @override
  String toString() {
    return 'CameraOptions(resolution: $resolution, lens: $lens, fps: $fps, zoom: $zoom)';
  }
} 