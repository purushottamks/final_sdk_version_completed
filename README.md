<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Flutter Camera Effects SDK

A cross-platform camera SDK with real-time filters and AR effects for Flutter, providing a unified API for iOS and Android.

## Features

- **Cross-Platform Compatibility**
  - Unified API for iOS & Android
  - Consistent behavior across platforms
  - GPU-accelerated processing (Metal for iOS, OpenGL/Vulkan for Android)

- **Camera Control**
  - Start/stop camera
  - Switch between front/back cameras
  - Adjust resolution, FPS, and zoom
  - Flash/torch control
  - Focus/exposure adjustment

- **Media Capture**
  - High-quality photo capture
  - Video recording (with/without audio)
  - Live preview streaming
  - EXIF metadata support

- **Filter System**
  - Real-time filter pipeline
  - 10+ pre-built filters (beauty, sepia, B&W, etc.)
  - Custom LUT (Look-Up Table) support
  - Adjustable filter intensity

- **Face Effects**
  - Face detection (landmarks)
  - AR masks/overlays
  - Makeup/beautification
  - Face distortion (stretch, resize)

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_camera_effects: ^0.0.1
```

## Platform Setup

### iOS

Add the following to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos and videos</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record videos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to save photos and videos</string>
```

### Android

Add the following to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## Basic Usage

### Initialize the Camera

```dart
import 'package:flutter_camera_effects/flutter_camera_effects.dart';

// Initialize the SDK
final cameraSDK = CameraSDK();
await cameraSDK.init(
  options: CameraOptions(
    resolution: CameraResolution.high,
    lens: CameraLens.back,
    enableFaceDetection: true,
  ),
);
```

### Display Camera Preview

```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: cameraSDK.getPreviewWidget(
      fit: BoxFit.cover,
      enableFilters: true,
      showFaceTracking: true,
    ),
  );
}
```

### Take a Photo

```dart
final photo = await cameraSDK.takePhoto(
  applyFilter: true,
  applyAREffect: true,
  saveToGallery: true,
);

// Access the photo data
print('Photo path: ${photo.path}');
print('Photo size: ${photo.width}x${photo.height}');
```

### Record a Video

```dart
// Start recording
await cameraSDK.startVideoRecording(
  applyFilter: true,
  applyAREffect: true,
  maxDuration: 30000, // 30 seconds
);

// Later, stop recording
final video = await cameraSDK.stopVideoRecording(
  saveToGallery: true,
);

// Access the video data
print('Video path: ${video.path}');
print('Video duration: ${video.durationInSeconds} seconds');
```

### Apply Filters

```dart
// Apply a preset filter
await cameraSDK.applyFilter(PresetFilters.sepia);

// Apply a custom filter with intensity
await cameraSDK.applyFilter(PresetFilters.brightness(intensity: 0.7));

// Clear the filter
await cameraSDK.clearFilter();
```

### Apply AR Effects

```dart
// Apply a preset AR effect
await cameraSDK.applyAREffect(PresetAREffects.dogMask);

// Apply a beauty effect
await cameraSDK.applyAREffect(PresetAREffects.beautyPlus);

// Clear the AR effect
await cameraSDK.clearAREffect();
```

### Camera Controls

```dart
// Switch between front and back cameras
await cameraSDK.switchCamera();

// Set flash mode
await cameraSDK.setFlashMode(FlashMode.auto);

// Set zoom level (1.0 is no zoom)
await cameraSDK.setZoom(2.0);
```

### Custom Filter Selector UI

```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Camera preview
        cameraSDK.getPreviewWidget(),
        
        // Filter selector at the bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: FilterSelector(
            controller: cameraSDK.controller!,
            onFilterSelected: (filter) {
              print('Selected filter: ${filter.name}');
            },
          ),
        ),
      ],
    ),
  );
}
```

## Advanced Usage

### Custom LUT Filters

```dart
// Create a custom LUT filter
final lutFilter = PresetFilters.customLut(
  name: 'MyLUT',
  lutPath: 'assets/filters/my_lut.png',
  intensity: 0.8,
);

// Apply the custom LUT filter
await cameraSDK.applyFilter(lutFilter);
```

### Face Detection

```dart
// Listen for face detection events
cameraSDK.detectedFacesNotifier.addListener(() {
  final faces = cameraSDK.detectedFaces;
  for (final face in faces) {
    print('Face detected: ${face.bounds}');
    
    // Check if the face is smiling
    if (face.isSmiling) {
      print('Person is smiling!');
    }
    
    // Get face landmarks
    for (final landmark in face.landmarks) {
      print('Landmark: ${landmark.type} at ${landmark.position}');
    }
  }
});
```

### Cleanup

```dart
@override
void dispose() {
  // Dispose the camera SDK
  cameraSDK.dispose();
  super.dispose();
}
```

## Custom AR Effects

You can create custom AR effects:

```dart
// Create a custom mask effect
final customMask = MaskEffect(
  id: 'custom_mask',
  name: 'My Custom Mask',
  maskPath: 'assets/ar/my_mask.png',
  trackFace: true,
  intensity: 0.9,
);

// Apply the custom mask
await cameraSDK.applyAREffect(customMask);
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
