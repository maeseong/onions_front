import 'package:flutter/material.dart';

class GroundPlot extends StatelessWidget {
  final double width;
  final double height;
  final Color? baseColor; // 옆면 흙 색상
  final Color? surfaceColor; // 상단 잔디 색상
  final double elevation; // 입체감 두께

  const GroundPlot({
    super.key,
    this.width = 320,
    this.height = 160,
    this.baseColor,
    this.surfaceColor,
    this.elevation = 30,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveSurfaceColor = surfaceColor ?? const Color(0xFF61B099);
    final Color effectiveBaseColor = baseColor ?? const Color(0xFF795548); // 기본 흙색

    return Center(
      child: CustomPaint(
        size: Size(width, height + elevation),
        painter: _GroundPainter(
          width: width,
          height: height,
          baseColor: effectiveBaseColor,
          surfaceColor: effectiveSurfaceColor,
          elevation: elevation,
        ),
      ),
    );
  }
}

class _GroundPainter extends CustomPainter {
  final double width;
  final double height;
  final Color baseColor;
  final Color surfaceColor;
  final double elevation;

  _GroundPainter({
    required this.width,
    required this.height,
    required this.baseColor,
    required this.surfaceColor,
    required this.elevation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint surfacePaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;

    // 옆면 흙
    final Paint sideDarkPaint = Paint()
      ..color = baseColor.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    final Paint sideLightPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    // 아이소메트릭 좌표 계산
    final Offset top = Offset(size.width / 2, 0);
    final Offset bottom = Offset(size.width / 2, height);
    final Offset left = Offset(0, height / 2);
    final Offset right = Offset(size.width, height / 2);

    // 상단 잔디면
    final Path surfacePath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(surfacePath, surfacePaint);

    // 오른쪽 측면
    final Path rightSide = Path()
      ..moveTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(bottom.dx, bottom.dy + elevation)
      ..lineTo(right.dx, right.dy + elevation)
      ..close();
    canvas.drawPath(rightSide, sideDarkPaint);

    // 왼쪽 측면
    final Path leftSide = Path()
      ..moveTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(left.dx, left.dy + elevation)
      ..lineTo(bottom.dx, bottom.dy + elevation)
      ..close();
    canvas.drawPath(leftSide, sideLightPaint);
    
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(surfacePath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _GroundPainter oldDelegate) => false;
}