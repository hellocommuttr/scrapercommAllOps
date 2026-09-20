import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Commuttr's mark: a route line between two stops, drawn rather than shipped as an
/// image so it stays crisp and costs nothing to download.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Commuttr',
    image: true,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Brand.orangeDeep, borderRadius: BorderRadius.circular(size * 0.28)),
      child: CustomPaint(painter: _RoutePainter()),
    ),
  );
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final line = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.08
      ..strokeCap = StrokeCap.round;
    final a = Offset(s.width * 0.28, s.height * 0.70);
    final b = Offset(s.width * 0.72, s.height * 0.30);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(s.width * 0.62, s.height * 0.72, s.width * 0.38, s.height * 0.28, b.dx, b.dy);
    canvas.drawPath(path, line);
    final dot = Paint()..color = Colors.white;
    canvas.drawCircle(a, s.width * 0.09, dot);
    canvas.drawCircle(b, s.width * 0.09, line..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
