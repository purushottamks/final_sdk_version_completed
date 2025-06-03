import 'package:flutter/material.dart';
import '../core/camera_controller.dart';

/// A widget that displays the camera preview
class CameraPreview extends StatelessWidget {
  /// The camera controller
  final CameraController controller;
  
  /// Box fit for the preview
  final BoxFit fit;
  
  /// Whether to apply filters in real-time
  final bool enableFilters;
  
  /// Whether to show face tracking UI elements
  final bool showFaceTracking;
  
  /// Widget to overlay on top of the camera preview
  final Widget? overlay;
  
  /// Filter strength (0.0-1.0)
  final double filterStrength;
  
  /// Border radius for the preview
  final BorderRadius? borderRadius;

  /// Creates a CameraPreview instance
  const CameraPreview({
    Key? key,
    required this.controller,
    this.fit = BoxFit.cover,
    this.enableFilters = true,
    this.showFaceTracking = false,
    this.overlay,
    this.filterStrength = 1.0,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: ValueListenableBuilder<bool>(
        valueListenable: controller.isInitializedNotifier,
        builder: (context, isInitialized, child) {
          if (!isInitialized) {
            return Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera preview from texture
              _buildCameraPreview(),
              
              // Face tracking overlay if enabled
              if (showFaceTracking) _buildFaceTrackingOverlay(),
              
              // Custom overlay
              if (overlay != null) overlay!,
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraPreview() {
    return FittedBox(
      fit: fit,
      child: SizedBox(
        width: controller.previewSize.width,
        height: controller.previewSize.height,
        child: Texture(
          textureId: controller.textureId,
          filterQuality: FilterQuality.low,
        ),
      ),
    );
  }

  Widget _buildFaceTrackingOverlay() {
    return ValueListenableBuilder(
      valueListenable: controller.detectedFacesNotifier,
      builder: (context, faces, _) {
        return CustomPaint(
          painter: FaceTrackingPainter(faces: faces),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom painter to draw face tracking boxes
class FaceTrackingPainter extends CustomPainter {
  /// The detected faces
  final List<dynamic> faces;

  /// Creates a FaceTrackingPainter instance
  FaceTrackingPainter({required this.faces});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final face in faces) {
      final rect = Rect.fromLTRB(
        face.bounds.left * size.width,
        face.bounds.top * size.height,
        face.bounds.right * size.width,
        face.bounds.bottom * size.height,
      );
      
      canvas.drawRect(rect, paint);
      
      // Draw face landmarks if available
      for (final landmark in face.landmarks) {
        final point = Offset(
          landmark.position.x * size.width,
          landmark.position.y * size.height,
        );
        
        canvas.drawCircle(point, 2, paint..color = Colors.red);
      }
    }
  }

  @override
  bool shouldRepaint(FaceTrackingPainter oldDelegate) => true;
} 