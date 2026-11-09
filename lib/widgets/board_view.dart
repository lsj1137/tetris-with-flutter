import 'package:flutter/material.dart';

import '../game/tetromino.dart';
import 'tetromino_color.dart';

/// 테트리스 판. 주어진 공간 안에서 칸이 정사각형이 되도록 맞춘다.
class BoardView extends StatelessWidget {
  const BoardView({super.key, required this.cells});

  /// [행][열] 칸 상태. 빈칸은 null.
  final List<List<Tetromino?>> cells;

  static const Color background = Color(0xFF1E2235);
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final rows = cells.length;
    final columns = cells[0].length;
    return AspectRatio(
      aspectRatio: columns / rows,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: background,
          borderRadius: _radius,
          boxShadow: [
            BoxShadow(
                color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: _radius,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CustomPaint(painter: _BoardPainter(cells)),
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter(this.cells);

  final List<List<Tetromino?>> cells;

  static const Color _emptyCell = Color(0xFF2A2F47);
  static const Color _highlight = Color(0x40FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final rows = cells.length;
    final columns = cells[0].length;
    final cellSize = size.width / columns;
    final gap = cellSize * 0.06;
    final radius = Radius.circular(cellSize * 0.18);
    final paint = Paint();

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        final rect =
            Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize)
                .deflate(gap);
        final type = cells[r][c];
        paint.color = type?.color ?? _emptyCell;
        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
        if (type != null) {
          // 위쪽에 옅은 광택
          final shine = Rect.fromLTWH(
              rect.left, rect.top, rect.width, rect.height * 0.35);
          paint.color = _highlight;
          canvas.drawRRect(
            RRect.fromRectAndCorners(shine, topLeft: radius, topRight: radius),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_BoardPainter oldDelegate) => true;
}
