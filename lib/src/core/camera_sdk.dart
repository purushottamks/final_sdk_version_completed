import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_controller.dart';
import 'camera_options.dart';
import 'photo.dart';
import 'video.dart';
import '../widgets/camera_preview.dart';
import '../filters/filter.dart';
import '../ar/ar_effect.dart';
import '../utils/permission_handler.dart';

/// Main SDK class for camera access and functionality
class CameraSDK {
  /// Camera controller instance
  CameraController? _controller;

  /// Whether the SDK has been initialized
  bool _isInitialized = false;

  /// Single instance of the SDK (singleton)
  static final CameraSDK _instance = CameraSDK._();

  /// Private constructor
  CameraSDK._();

  /// Get the singleton instance
  factory CameraSDK() => _instance;

  /// Initialize the SDK with given options
  Future<void> init({
    CameraOptions options = const CameraOptions(),
    bool requestPermissions = true,
  }) async {
    if (_isInitialized) {
      return;
    }

    if (requestPermissions) {
      final hasPermissions = await CameraPermissions.requestAllPermissions(
        requestAudio: options.enableAudio,
      );
      
      // Check if the camera permission was granted
      if (!hasPermissions[Permission.camera]!.isGranted) {
        throw CameraException(
          code: 'permissionDenied',
          description: 'Camera permission denied',
        );
      }
    }

    _controller = CameraController(options: options);
    await _controller!.initialize();
    await _controller!.startPreview();
    
    _isInitialized = true;
  }

  /// Get a preview widget for the camera
  Widget getPreviewWidget({
    BoxFit fit = BoxFit.cover,
    bool enableFilters = true,
    bool showFaceTracking = false,
    Widget? overlay,
    BorderRadius? borderRadius,
  }) {
    _assertInitialized();
    
    return CameraPreview(
      controller: _controller!,
      fit: fit,
      enableFilters: enableFilters,
      showFaceTracking: showFaceTracking,
      overlay: overlay,
      borderRadius: borderRadius,
    );
  }

  /// Take a photo
  Future<Photo> takePhoto({
    bool applyFilter = true,
    bool applyAREffect = true,
    bool saveToGallery = false,
  }) async {
    _assertInitialized();
    
    return await _controller!.takePhoto(
      applyFilter: applyFilter,
      applyAREffect: applyAREffect,
      saveToGallery: saveToGallery,
    );
  }

  /// Start video recording
  Future<void> startVideoRecording({
    bool applyFilter = true,
    bool applyAREffect = true,
    int? maxDuration,
    String? filePath,
  }) async {
    _assertInitialized();
    
    return await _controller!.startVideoRecording(
      applyFilter: applyFilter,
      applyAREffect: applyAREffect,
      maxDuration: maxDuration,
      filePath: filePath,
    );
  }

  /// Stop video recording
  Future<Video> stopVideoRecording({
    bool saveToGallery = false,
  }) async {
    _assertInitialized();
    
    return await _controller!.stopVideoRecording(
      saveToGallery: saveToGallery,
    );
  }

  /// Apply a filter
  Future<void> applyFilter(Filter filter) async {
    _assertInitialized();
    
    return await _controller!.setFilter(filter);
  }

  /// Clear any active filter
  Future<void> clearFilter() async {
    _assertInitialized();
    
    return await _controller!.clearFilter();
  }

  /// Apply an AR effect
  Future<void> applyAREffect(AREffect effect) async {
    _assertInitialized();
    
    return await _controller!.setAREffect(effect);
  }

  /// Clear any active AR effect
  Future<void> clearAREffect() async {
    _assertInitialized();
    
    return await _controller!.clearAREffect();
  }

  /// Switch between front and back cameras
  Future<void> switchCamera() async {
    _assertInitialized();
    
    return await _controller!.switchCamera();
  }

  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    _assertInitialized();
    
    return await _controller!.setFlashMode(mode);
  }

  /// Set zoom level
  Future<void> setZoom(double zoom) async {
    _assertInitialized();
    
    return await _controller!.setZoom(zoom);
  }

  /// Enable or disable face detection
  Future<void> setFaceDetectionEnabled(bool enabled) async {
    _assertInitialized();
    
    return await _controller!.setFaceDetectionEnabled(enabled);
  }

  /// Get whether the SDK is initialized
  bool get isInitialized => _isInitialized;

  /// Get the camera controller for advanced operations
  CameraController? get controller => _controller;

  /// Get whether recording is in progress
  bool get isRecording => _controller?.isRecording ?? false;

  /// Get the active filter
  Filter? get activeFilter => _controller?.activeFilter;

  /// Get the active AR effect
  AREffect? get activeEffect => _controller?.activeEffect;

  /// Get the detected faces
  List<dynamic> get detectedFaces => _controller?.detectedFaces ?? [];

  /// Listen to face detection events
  ValueNotifier<List<dynamic>> get detectedFacesNotifier => 
      _controller?.detectedFacesNotifier ?? ValueNotifier([]);

  /// Dispose the SDK and release resources
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    
    _isInitialized = false;
  }

  /// Assert that the SDK is initialized
  void _assertInitialized() {
    if (!_isInitialized || _controller == null) {
      throw CameraException(
        code: 'notInitialized',
        description: 'Camera SDK is not initialized',
      );
    }
  }
} 