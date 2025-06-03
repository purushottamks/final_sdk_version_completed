import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' show Point;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'camera_options.dart';
import 'photo.dart';
import 'video.dart';
import '../filters/filter.dart';
import '../filters/preset_filters.dart';
import '../ar/face_detection.dart';
import '../ar/ar_effect.dart';

/// Main camera controller class that manages the camera state and operations
class CameraController {
  /// The method channel for communicating with the native platform
  final MethodChannel _methodChannel;
  
  /// The event channel for receiving real-time events from the native platform
  final EventChannel _eventChannel;
  
  /// Current camera options
  CameraOptions _options;
  
  /// Texture ID for the camera preview
  late int _textureId;
  
  /// Stream subscription for camera events
  StreamSubscription? _eventsSubscription;
  
  /// Whether the controller is initialized
  bool _isInitialized = false;
  
  /// Whether recording is currently in progress
  bool _isRecording = false;
  
  /// Size of the preview in pixels
  Size _previewSize = const Size(1280, 720);
  
  /// Currently active filter
  Filter? _activeFilter;
  
  /// Currently active AR effect
  AREffect? _activeEffect;
  
  /// Currently detected faces
  List<DetectedFace> _detectedFaces = [];

  /// Notifier for initialization state
  final ValueNotifier<bool> isInitializedNotifier = ValueNotifier(false);
  
  /// Notifier for recording state
  final ValueNotifier<bool> isRecordingNotifier = ValueNotifier(false);
  
  /// Notifier for active filter
  final ValueNotifier<Filter?> activeFilterNotifier = ValueNotifier(null);
  
  /// Notifier for active AR effect
  final ValueNotifier<AREffect?> activeEffectNotifier = ValueNotifier(null);
  
  /// Notifier for detected faces
  final ValueNotifier<List<DetectedFace>> detectedFacesNotifier = ValueNotifier([]);

  /// Creates a CameraController instance
  CameraController({
    CameraOptions options = const CameraOptions(),
    String methodChannelName = 'com.example.flutter_camera_effects/method',
    String eventChannelName = 'com.example.flutter_camera_effects/event',
  })  : _options = options,
        _methodChannel = MethodChannel(methodChannelName),
        _eventChannel = EventChannel(eventChannelName);

  /// Initialize the camera
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'initialize',
        _options.toMap(),
      );

      _textureId = result!['textureId'] as int;
      _previewSize = Size(
        result['previewWidth'] as double,
        result['previewHeight'] as double,
      );

      _isInitialized = true;
      isInitializedNotifier.value = true;

      // Listen for camera events
      _eventsSubscription = _eventChannel.receiveBroadcastStream().listen(_handleEvent);
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'An unknown error occurred',
      );
    }
  }

  /// Start the camera preview
  Future<void> startPreview() async {
    _assertInitialized();

    try {
      await _methodChannel.invokeMethod<void>('startPreview');
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to start preview',
      );
    }
  }

  /// Stop the camera preview
  Future<void> stopPreview() async {
    _assertInitialized();

    try {
      await _methodChannel.invokeMethod<void>('stopPreview');
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to stop preview',
      );
    }
  }

  /// Switch between front and back cameras
  Future<void> switchCamera() async {
    _assertInitialized();

    final newLens = _options.lens == CameraLens.back
        ? CameraLens.front
        : CameraLens.back;

    try {
      await _methodChannel.invokeMethod<void>('switchCamera', {'lens': newLens.index});
      _options = _options.copyWith(lens: newLens);
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to switch camera',
      );
    }
  }

  /// Set a filter to use for preview and capture
  Future<void> setFilter(Filter filter) async {
    _assertInitialized();

    try {
      await _methodChannel.invokeMethod<void>('setFilter', {
        'filterId': filter.id,
        'filterType': filter.type.index,
        'intensity': filter.intensity,
        'params': filter.getParameters(),
        'lutPath': filter.getLutPath(),
        'shaderCode': filter.getShaderCode(),
      });
      
      _activeFilter = filter;
      activeFilterNotifier.value = filter;
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to set filter',
      );
    }
  }

  /// Remove any active filter
  Future<void> clearFilter() async {
    _assertInitialized();

    try {
      await setFilter(PresetFilters.none);
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to clear filter',
      );
    }
  }

  /// Apply an AR effect
  Future<void> setAREffect(AREffect effect) async {
    _assertInitialized();

    try {
      await _methodChannel.invokeMethod<void>('setAREffect', {
        'effectId': effect.id,
        'effectType': effect.type.index,
        'intensity': effect.intensity,
        'requiresFaceDetection': effect.requiresFaceDetection,
        // Add effect-specific parameters
        ...effect is MaskEffect
            ? {'maskPath': (effect as MaskEffect).maskPath, 'trackFace': (effect as MaskEffect).trackFace}
            : {},
        ...effect is BeautyEffect
            ? {
                'smoothing': (effect as BeautyEffect).smoothing,
                'whitening': (effect as BeautyEffect).whitening,
                'eyeEnlarge': (effect as BeautyEffect).eyeEnlarge,
                'faceSlim': (effect as BeautyEffect).faceSlim,
              }
            : {},
      });
      
      _activeEffect = effect;
      activeEffectNotifier.value = effect;
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to set AR effect',
      );
    }
  }

  /// Remove any active AR effect
  Future<void> clearAREffect() async {
    _assertInitialized();

    try {
      await _methodChannel.invokeMethod<void>('clearAREffect');
      _activeEffect = null;
      activeEffectNotifier.value = null;
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to clear AR effect',
      );
    }
  }

  /// Set zoom level
  Future<void> setZoom(double zoom) async {
    _assertInitialized();

    try {
      await _methodChannel.invokeMethod<void>('setZoom', {'zoom': zoom});
      _options = _options.copyWith(zoom: zoom);
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to set zoom',
      );
    }
  }

  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    _assertInitialized();

    try {
      await _methodChannel.invokeMethod<void>('setFlashMode', {'mode': mode.index});
      _options = _options.copyWith(flashMode: mode);
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to set flash mode',
      );
    }
  }

  /// Take a photo
  Future<Photo> takePhoto({
    bool applyFilter = true,
    bool applyAREffect = true,
    bool saveToGallery = false,
  }) async {
    _assertInitialized();

    try {
      final String? tempPath = await _createTempFilePath('.jpg');
      
      final Map<String, dynamic> result = await _methodChannel.invokeMapMethod(
        'takePhoto',
        {
          'applyFilter': applyFilter,
          'applyAREffect': applyAREffect,
          'saveToGallery': saveToGallery,
          'path': tempPath,
        },
      ) as Map<String, dynamic>;

      final Uint8List bytes = result['bytes'] as Uint8List;
      final int width = result['width'] as int;
      final int height = result['height'] as int;
      final String path = result['path'] as String;
      final Map<String, dynamic>? metadata = result['metadata'] as Map<String, dynamic>?;

      return Photo(
        bytes: bytes,
        width: width,
        height: height,
        path: path,
        metadata: metadata,
      );
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to take photo',
      );
    }
  }

  /// Start video recording
  Future<void> startVideoRecording({
    bool applyFilter = true,
    bool applyAREffect = true,
    int? maxDuration,
    String? filePath,
  }) async {
    _assertInitialized();

    if (_isRecording) {
      throw CameraException(
        code: 'alreadyRecording',
        description: 'Video recording is already in progress',
      );
    }

    try {
      final path = filePath ?? await _createTempFilePath('.mp4');
      
      await _methodChannel.invokeMethod<void>(
        'startRecording',
        {
          'applyFilter': applyFilter,
          'applyAREffect': applyAREffect,
          'maxDuration': maxDuration,
          'path': path,
        },
      );
      
      _isRecording = true;
      isRecordingNotifier.value = true;
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to start recording',
      );
    }
  }

  /// Stop video recording
  Future<Video> stopVideoRecording({bool saveToGallery = false}) async {
    _assertInitialized();

    if (!_isRecording) {
      throw CameraException(
        code: 'notRecording',
        description: 'No video recording in progress',
      );
    }

    try {
      final Map<String, dynamic> result = await _methodChannel.invokeMapMethod(
        'stopRecording',
        {'saveToGallery': saveToGallery},
      ) as Map<String, dynamic>;

      _isRecording = false;
      isRecordingNotifier.value = false;

      final String path = result['path'] as String;
      final int durationMs = result['durationMs'] as int;
      final int width = result['width'] as int;
      final int height = result['height'] as int;
      final int fps = result['fps'] as int;
      final bool hasAudio = result['hasAudio'] as bool;
      final Map<String, dynamic>? metadata = result['metadata'] as Map<String, dynamic>?;

      return Video(
        path: path,
        durationMs: durationMs,
        width: width,
        height: height,
        fps: fps,
        hasAudio: hasAudio,
        metadata: metadata,
      );
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to stop recording',
      );
    }
  }

  /// Enable or disable face detection
  Future<void> setFaceDetectionEnabled(bool enabled) async {
    _assertInitialized();

    try {
      await _methodChannel.invokeMethod<void>(
        'setFaceDetectionEnabled',
        {'enabled': enabled},
      );
      
      _options = _options.copyWith(enableFaceDetection: enabled);
    } on PlatformException catch (e) {
      throw CameraException(
        code: e.code,
        description: e.message ?? 'Failed to set face detection',
      );
    }
  }

  /// Dispose the controller and release resources
  Future<void> dispose() async {
    if (_eventsSubscription != null) {
      await _eventsSubscription!.cancel();
      _eventsSubscription = null;
    }

    if (_isInitialized) {
      try {
        await _methodChannel.invokeMethod<void>('dispose');
      } on PlatformException catch (e) {
        throw CameraException(
          code: e.code,
          description: e.message ?? 'Failed to dispose camera',
        );
      }
      
      _isInitialized = false;
      isInitializedNotifier.value = false;
    }
  }

  /// Get the texture ID for the preview
  int get textureId {
    _assertInitialized();
    return _textureId;
  }

  /// Get the size of the preview in pixels
  Size get previewSize {
    _assertInitialized();
    return _previewSize;
  }

  /// Get the current camera options
  CameraOptions get options => _options;

  /// Get whether the controller is initialized
  bool get isInitialized => _isInitialized;

  /// Get whether recording is in progress
  bool get isRecording => _isRecording;

  /// Get the currently active filter
  Filter? get activeFilter => _activeFilter;

  /// Get the currently active AR effect
  AREffect? get activeEffect => _activeEffect;

  /// Get the currently detected faces
  List<DetectedFace> get detectedFaces => _detectedFaces;

  /// Assert that the controller is initialized
  void _assertInitialized() {
    if (!_isInitialized) {
      throw CameraException(
        code: 'notInitialized',
        description: 'Camera controller is not initialized',
      );
    }
  }

  /// Create a temporary file path
  Future<String> _createTempFilePath(String extension) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final String filePath = path.join(
      tempPath,
      'camera_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    return filePath;
  }

  /// Handle events from the native platform
  void _handleEvent(dynamic event) {
    if (event is Map<dynamic, dynamic>) {
      final String eventName = event['event'] as String;
      
      switch (eventName) {
        case 'faceDetection':
          _handleFaceDetectionEvent(event);
          break;
        case 'error':
          _handleErrorEvent(event);
          break;
        case 'cameraClosing':
          _handleCameraClosingEvent();
          break;
      }
    }
  }

  /// Handle face detection events
  void _handleFaceDetectionEvent(Map<dynamic, dynamic> event) {
    final List<dynamic> facesData = event['faces'] as List<dynamic>;
    _detectedFaces = facesData.map((faceData) {
      final Map<dynamic, dynamic> boundsData = faceData['bounds'] as Map<dynamic, dynamic>;
      
      return DetectedFace(
        id: faceData['id'] as int,
        bounds: FaceRect(
          left: boundsData['left'] as double,
          top: boundsData['top'] as double,
          right: boundsData['right'] as double,
          bottom: boundsData['bottom'] as double,
        ),
        confidence: faceData['confidence'] as double,
        landmarks: (faceData['landmarks'] as List<dynamic>).map((landmarkData) {
          return FaceLandmark(
            type: LandmarkType.values[(landmarkData['type'] as int)],
            position: Point(
              landmarkData['x'] as double,
              landmarkData['y'] as double,
            ),
          );
        }).toList(),
        attributes: FaceAttributes(
          smileProbability: faceData['smileProbability'] as double? ?? 0.0,
          leftEyeOpenProbability: faceData['leftEyeOpenProbability'] as double? ?? 1.0,
          rightEyeOpenProbability: faceData['rightEyeOpenProbability'] as double? ?? 1.0,
          yawAngle: faceData['yawAngle'] as double? ?? 0.0,
          pitchAngle: faceData['pitchAngle'] as double? ?? 0.0,
          rollAngle: faceData['rollAngle'] as double? ?? 0.0,
        ),
        isTracking: faceData['isTracking'] as bool? ?? false,
      );
    }).toList();
    
    detectedFacesNotifier.value = List.from(_detectedFaces);
  }

  /// Handle error events
  void _handleErrorEvent(Map<dynamic, dynamic> event) {
    final String code = event['code'] as String;
    final String description = event['description'] as String;
    
    throw CameraException(
      code: code,
      description: description,
    );
  }

  /// Handle camera closing events
  void _handleCameraClosingEvent() {
    _isInitialized = false;
    isInitializedNotifier.value = false;
  }
}

/// Extension to convert CameraOptions to a map
extension CameraOptionsToMap on CameraOptions {
  Map<String, dynamic> toMap() {
    return {
      'resolution': resolution.index,
      'lens': lens.index,
      'flashMode': flashMode.index,
      'fps': fps,
      'zoom': zoom,
      'enableFaceDetection': enableFaceDetection,
      'enableAudio': enableAudio,
      'customWidth': customWidth,
      'customHeight': customHeight,
    };
  }
}

/// Exception thrown when a camera operation fails
class CameraException implements Exception {
  /// Error code
  final String code;
  
  /// Error description
  final String description;

  /// Creates a CameraException
  CameraException({
    required this.code,
    required this.description,
  });

  @override
  String toString() => 'CameraException($code, $description)';
} 