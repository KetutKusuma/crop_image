import 'package:crop_image/src/crop_rect.dart';
import 'package:flutter/material.dart';

/// Crop Grid with invisible border, for better touch detection.
class CropGrid extends StatelessWidget {
  final Rect crop;
  final Color gridColor;
  final Color gridInnerColor;
  final Color gridCornerColor;
  final double paddingSize;
  final double cornerSize;
  final bool showCorners;
  final double thinWidth;
  final double thickWidth;
  final Color scrimColor;
  final bool alwaysShowThirdLines;
  final bool isMoving;
  final ValueChanged<Size> onSize;
  final bool addCircleGrid;

  const CropGrid({
    super.key,
    required this.crop,
    required this.gridColor,
    required this.gridInnerColor,
    required this.gridCornerColor,
    required this.paddingSize,
    required this.cornerSize,
    required this.thinWidth,
    required this.thickWidth,
    required this.scrimColor,
    required this.showCorners,
    required this.alwaysShowThirdLines,
    required this.isMoving,
    required this.onSize,
    this.addCircleGrid = true,
  });

  @override
  Widget build(BuildContext context) => RepaintBoundary(child: CustomPaint(foregroundPainter: _CropGridPainter(this)));
}

class _CropGridPainter extends CustomPainter {
  final CropGrid grid;

  _CropGridPainter(this.grid);

  @override
  bool hitTest(Offset position) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Size imageSize = Size(size.width - 2 * grid.paddingSize, size.height - 2 * grid.paddingSize);
    final Rect bounds = grid.crop.multiply(imageSize).translate(grid.paddingSize, grid.paddingSize);
    grid.onSize(imageSize);

    canvas.save();

    if (grid.addCircleGrid) {
      // ==== SCRIM (gelap di luar lingkaran) ====
      final Rect circleRect = Rect.fromCenter(center: bounds.center, width: bounds.shortestSide, height: bounds.shortestSide);

      final Path outer = Path()..addRect(Rect.fromLTWH(25, 25, imageSize.width, imageSize.height));
      final Path circle = Path()..addOval(circleRect);

      final Path diff = Path.combine(PathOperation.difference, outer, circle);

      canvas.drawPath(
        diff,
        Paint()
          ..color = grid.scrimColor.withOpacity(0.5) // atur gelap/terangnya
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );

      // ==== BORDER LINGKARAN ====
      canvas.drawOval(
        circleRect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = grid.thickWidth
          ..strokeCap = StrokeCap.butt
          ..isAntiAlias = true,
      );
    }

    canvas.restore();

    canvas.drawPath(
      Path() //
        ..addPolygon([bounds.topLeft.translate(grid.cornerSize, 0), bounds.topRight.translate(-grid.cornerSize, 0)], false)
        ..addPolygon([bounds.bottomLeft.translate(grid.cornerSize, 0), bounds.bottomRight.translate(-grid.cornerSize, 0)], false)
        ..addPolygon([bounds.topLeft.translate(0, grid.cornerSize), bounds.bottomLeft.translate(0, -grid.cornerSize)], false)
        ..addPolygon([bounds.topRight.translate(0, grid.cornerSize), bounds.bottomRight.translate(0, -grid.cornerSize)], false),
      Paint()
        ..color = grid.gridColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = grid.thinWidth
        ..strokeCap = StrokeCap.butt
        ..isAntiAlias = true,
    );

    if (grid.isMoving || grid.alwaysShowThirdLines) {
      double hGrid = 0;
      if (grid.addCircleGrid) hGrid = 5;
      final thirdHeight = bounds.height / 3.0;
      final thirdWidth = bounds.width / 3.0;

      final trsPlus = (hGrid * 1);
      final trsMin = (hGrid * -1);
      canvas.drawPath(
        Path() //
          ..addPolygon([bounds.topLeft.translate(trsPlus, thirdHeight), bounds.topRight.translate(trsMin, thirdHeight)], false)
          ..addPolygon([bounds.bottomLeft.translate(trsPlus, -thirdHeight), bounds.bottomRight.translate(trsMin, -thirdHeight)], false)
          ..addPolygon([bounds.topLeft.translate(thirdWidth, trsPlus), bounds.bottomLeft.translate(thirdWidth, trsMin)], false)
          ..addPolygon([bounds.topRight.translate(-thirdWidth, trsPlus), bounds.bottomRight.translate(-thirdWidth, trsMin)], false),
        Paint()
          ..color = grid.gridInnerColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = grid.thinWidth
          ..strokeCap = StrokeCap.butt
          ..isAntiAlias = true,
      );
    }

    // ==== CORNER "L" MARKERS ====
    final Paint cornerPaint = Paint()
      ..color = grid.gridCornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = grid.thickWidth
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = true;

    final double cornerLength = grid.cornerSize * 2;

    // Top-left corner
    canvas.drawLine(bounds.topLeft, bounds.topLeft.translate(cornerLength, 0), cornerPaint);
    canvas.drawLine(bounds.topLeft, bounds.topLeft.translate(0, cornerLength), cornerPaint);

    // Top-right corner
    canvas.drawLine(bounds.topRight, bounds.topRight.translate(-cornerLength, 0), cornerPaint);
    canvas.drawLine(bounds.topRight, bounds.topRight.translate(0, cornerLength), cornerPaint);

    // Bottom-left corner
    canvas.drawLine(bounds.bottomLeft, bounds.bottomLeft.translate(cornerLength, 0), cornerPaint);
    canvas.drawLine(bounds.bottomLeft, bounds.bottomLeft.translate(0, -cornerLength), cornerPaint);

    // Bottom-right corner
    canvas.drawLine(bounds.bottomRight, bounds.bottomRight.translate(-cornerLength, 0), cornerPaint);
    canvas.drawLine(bounds.bottomRight, bounds.bottomRight.translate(0, -cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(_CropGridPainter oldDelegate) =>
      oldDelegate.grid.crop != grid.crop || //
      oldDelegate.grid.isMoving != grid.isMoving ||
      oldDelegate.grid.cornerSize != grid.cornerSize ||
      oldDelegate.grid.gridColor != grid.gridColor ||
      oldDelegate.grid.gridCornerColor != grid.gridCornerColor ||
      oldDelegate.grid.gridInnerColor != grid.gridInnerColor;
}
