import 'dart:math';

/// A class representing a detected face in the camera preview
class DetectedFace {
  /// Unique ID for tracking the face across frames
  final int id;
  
  /// Rectangle representing face bounds in normalized coordinates (0.0-1.0)
  final FaceRect bounds;
  
  /// The confidence score of the detection (0.0-1.0)
  final double confidence;
  
  /// Face landmarks (eyes, nose, mouth, etc.)
  final List<FaceLandmark> landmarks;
  
  /// Face attributes (age, gender, expression, etc.)
  final FaceAttributes attributes;
  
  /// True if this face is being tracked across frames
  final bool isTracking;

  /// Creates a DetectedFace instance
  DetectedFace({
    required this.id,
    required this.bounds,
    required this.confidence,
    this.landmarks = const [],
    this.attributes = const FaceAttributes(),
    this.isTracking = false,
  });

  /// Get the center point of the face
  Point<double> get center => bounds.center;

  /// Get the estimated size of the face
  double get size => (bounds.width + bounds.height) / 2;

  /// Check if the face is smiling
  bool get isSmiling => attributes.smileProbability > 0.7;

  /// Get eyes open state
  bool get hasEyesOpen => 
      attributes.leftEyeOpenProbability > 0.7 && 
      attributes.rightEyeOpenProbability > 0.7;

  /// Get the roll angle of the face
  double get rollAngle => attributes.rollAngle;

  /// Create a copy with updated properties
  DetectedFace copyWith({
    int? id,
    FaceRect? bounds,
    double? confidence,
    List<FaceLandmark>? landmarks,
    FaceAttributes? attributes,
    bool? isTracking,
  }) {
    return DetectedFace(
      id: id ?? this.id,
      bounds: bounds ?? this.bounds,
      confidence: confidence ?? this.confidence,
      landmarks: landmarks ?? this.landmarks,
      attributes: attributes ?? this.attributes,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}

/// Rectangle representing face bounds
class FaceRect {
  /// Left coordinate (0.0-1.0)
  final double left;
  
  /// Top coordinate (0.0-1.0)
  final double top;
  
  /// Right coordinate (0.0-1.0)
  final double right;
  
  /// Bottom coordinate (0.0-1.0)
  final double bottom;

  /// Creates a FaceRect instance
  const FaceRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// Width of the rectangle
  double get width => right - left;

  /// Height of the rectangle
  double get height => bottom - top;

  /// Center point of the rectangle
  Point<double> get center => Point(left + width / 2, top + height / 2);

  /// Create a FaceRect from absolute coordinates
  factory FaceRect.fromAbsolute({
    required double left,
    required double top,
    required double right,
    required double bottom,
    required int imageWidth,
    required int imageHeight,
  }) {
    return FaceRect(
      left: left / imageWidth,
      top: top / imageHeight,
      right: right / imageWidth,
      bottom: bottom / imageHeight,
    );
  }

  /// Get absolute coordinates for a specific image size
  Map<String, double> toAbsolute(int imageWidth, int imageHeight) {
    return {
      'left': left * imageWidth,
      'top': top * imageHeight,
      'right': right * imageWidth,
      'bottom': bottom * imageHeight,
      'width': width * imageWidth,
      'height': height * imageHeight,
    };
  }
}

/// Landmark types for face detection
enum LandmarkType {
  /// The left eye
  leftEye,
  
  /// The right eye
  rightEye,
  
  /// The left ear
  leftEar,
  
  /// The right ear
  rightEar,
  
  /// The left cheek
  leftCheek,
  
  /// The right cheek
  rightCheek,
  
  /// The nose base
  noseBase,
  
  /// The left mouth corner
  mouthLeft,
  
  /// The right mouth corner
  mouthRight,
  
  /// The bottom lip 
  bottomLip,
  
  /// The top lip
  topLip
}

/// A facial landmark with position
class FaceLandmark {
  /// The type of landmark
  final LandmarkType type;
  
  /// Position (x,y) in normalized coordinates (0.0-1.0)
  final Point<double> position;

  /// Creates a FaceLandmark instance
  const FaceLandmark({
    required this.type,
    required this.position,
  });

  /// Create a landmark from absolute coordinates
  factory FaceLandmark.fromAbsolute({
    required LandmarkType type,
    required double x,
    required double y,
    required int imageWidth,
    required int imageHeight,
  }) {
    return FaceLandmark(
      type: type,
      position: Point(x / imageWidth, y / imageHeight),
    );
  }

  /// Get absolute coordinates for a specific image size
  Map<String, double> toAbsolute(int imageWidth, int imageHeight) {
    return {
      'x': position.x * imageWidth,
      'y': position.y * imageHeight,
    };
  }
}

/// Attributes of a detected face
class FaceAttributes {
  /// Probability that the face is smiling (0.0-1.0)
  final double smileProbability;
  
  /// Probability that the left eye is open (0.0-1.0)
  final double leftEyeOpenProbability;
  
  /// Probability that the right eye is open (0.0-1.0)
  final double rightEyeOpenProbability;
  
  /// Euler Y angle (head turning left/right)
  final double yawAngle;
  
  /// Euler X angle (head tilting up/down)
  final double pitchAngle;
  
  /// Euler Z angle (head tilting left/right)
  final double rollAngle;

  /// Creates a FaceAttributes instance
  const FaceAttributes({
    this.smileProbability = 0.0,
    this.leftEyeOpenProbability = 1.0,
    this.rightEyeOpenProbability = 1.0,
    this.yawAngle = 0.0,
    this.pitchAngle = 0.0,
    this.rollAngle = 0.0,
  });

  /// Create a copy with updated properties
  FaceAttributes copyWith({
    double? smileProbability,
    double? leftEyeOpenProbability,
    double? rightEyeOpenProbability,
    double? yawAngle,
    double? pitchAngle,
    double? rollAngle,
  }) {
    return FaceAttributes(
      smileProbability: smileProbability ?? this.smileProbability,
      leftEyeOpenProbability: leftEyeOpenProbability ?? this.leftEyeOpenProbability,
      rightEyeOpenProbability: rightEyeOpenProbability ?? this.rightEyeOpenProbability,
      yawAngle: yawAngle ?? this.yawAngle,
      pitchAngle: pitchAngle ?? this.pitchAngle,
      rollAngle: rollAngle ?? this.rollAngle,
    );
  }
} 