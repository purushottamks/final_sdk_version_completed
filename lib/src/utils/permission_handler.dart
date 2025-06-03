import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

/// Utility class to handle camera and microphone permissions
class CameraPermissions {
  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if microphone permission is granted
  static Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Request all required permissions for camera functionality
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions({
    bool requestAudio = true,
    bool requestStorage = true,
  }) async {
    final permissions = <Permission>[Permission.camera];
    
    if (requestAudio) {
      permissions.add(Permission.microphone);
    }
    
    if (requestStorage) {
      permissions.add(Permission.storage);
    }
    
    return await permissions.request();
  }

  /// Check if all required permissions are granted
  static Future<bool> hasAllPermissions({
    bool checkAudio = true,
    bool checkStorage = true,
  }) async {
    final cameraStatus = await Permission.camera.status;
    
    if (!cameraStatus.isGranted) {
      return false;
    }
    
    if (checkAudio) {
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        return false;
      }
    }
    
    if (checkStorage) {
      final storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        return false;
      }
    }
    
    return true;
  }

  /// Open app settings so user can enable permissions manually
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
} 