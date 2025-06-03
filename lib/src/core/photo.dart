import 'dart:io';
import 'dart:typed_data';

/// A class representing a captured photo
class Photo {
  /// The path to the saved photo file
  final String? path;
  
  /// The raw bytes of the photo
  final Uint8List bytes;
  
  /// Width of the photo in pixels
  final int width;
  
  /// Height of the photo in pixels
  final int height;
  
  /// EXIF metadata for the photo
  final Map<String, dynamic>? metadata;

  /// Creates a Photo instance
  Photo({
    this.path,
    required this.bytes,
    required this.width,
    required this.height,
    this.metadata,
  });

  /// Get the aspect ratio of the photo
  double get aspectRatio => width / height;

  /// Get the File object if the photo is saved to disk
  File? get file => path != null ? File(path!) : null;

  /// Get the size of the photo in bytes
  int get size => bytes.length;

  /// Creates a Photo instance from raw bytes
  factory Photo.fromBytes({
    required Uint8List bytes,
    required int width,
    required int height,
    String? path,
    Map<String, dynamic>? metadata,
  }) {
    return Photo(
      bytes: bytes,
      width: width,
      height: height,
      path: path,
      metadata: metadata,
    );
  }

  /// Creates a Photo instance from a file
  factory Photo.fromFile({
    required File file,
    required int width,
    required int height,
    Map<String, dynamic>? metadata,
  }) {
    return Photo(
      path: file.path,
      bytes: file.readAsBytesSync(),
      width: width,
      height: height,
      metadata: metadata,
    );
  }
} 