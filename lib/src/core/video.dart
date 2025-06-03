import 'dart:io';

/// A class representing a recorded video
class Video {
  /// The path to the saved video file
  final String path;
  
  /// Duration of the video in milliseconds
  final int durationMs;
  
  /// Width of the video in pixels
  final int width;
  
  /// Height of the video in pixels
  final int height;
  
  /// The framerate of the video in frames per second
  final int fps;
  
  /// Whether the video has audio
  final bool hasAudio;
  
  /// Additional metadata for the video
  final Map<String, dynamic>? metadata;

  /// Creates a Video instance
  Video({
    required this.path,
    required this.durationMs,
    required this.width,
    required this.height,
    required this.fps,
    this.hasAudio = true,
    this.metadata,
  });

  /// Get the aspect ratio of the video
  double get aspectRatio => width / height;

  /// Get the duration in seconds
  double get durationInSeconds => durationMs / 1000.0;

  /// Get the File object
  File get file => File(path);

  /// Get the size of the video file in bytes
  int get size => file.lengthSync();

  /// Creates a Video instance from a file
  factory Video.fromFile({
    required File file,
    required int durationMs,
    required int width,
    required int height,
    required int fps,
    bool hasAudio = true,
    Map<String, dynamic>? metadata,
  }) {
    return Video(
      path: file.path,
      durationMs: durationMs,
      width: width,
      height: height,
      fps: fps,
      hasAudio: hasAudio,
      metadata: metadata,
    );
  }
} 