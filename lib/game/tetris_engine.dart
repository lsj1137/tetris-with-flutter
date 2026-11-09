import 'tetromino.dart';

/// 다음 블럭 공급자. 테스트에서 순서를 고정할 때 교체한다.
typedef PieceSource = Tetromino Function();

/// 현재 떨어지고 있는 블럭.
class ActivePiece {
  const ActivePiece(this.type, this.shape, this.row, this.col);

  final Tetromino type;
  final Shape shape;

  /// 블럭 모양의 왼쪽 위 칸 위치.
  final int row;
  final int col;

  ActivePiece moved(int dRow, int dCol) =>
      ActivePiece(type, shape, row + dRow, col + dCol);

  /// 칸이 차 있는 보드 좌표들.
  Iterable<(int, int)> get cells sync* {
    for (var r = 0; r < shape.length; r++) {
      for (var c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 1) yield (row + r, col + c);
      }
    }
  }
}

/// UI와 무관한 테트리스 규칙. 보드에는 바닥에 쌓인 블럭만 두고,
/// 떨어지는 블럭은 [piece]로 따로 들고 있다가 착지할 때 보드에 새긴다.
class TetrisEngine {
  TetrisEngine({this.rows = 20, this.columns = 10, PieceSource? nextPiece})
      : _nextPiece = nextPiece ?? SevenBag().next {
    reset();
  }

  static const int pointsPerLine = 10;
  static const int linesPerLevel = 3;

  /// 회전 시 벽·블럭에 막히면 좌우로 밀어보는 거리 순서.
  /// 왼쪽 위 기준으로 돌려 모양이 오른쪽으로 커지므로, 세로 I는 왼쪽으로 3칸까지 밀어야 한다.
  static const List<int> _kickOffsets = [0, -1, 1, -2, 2, -3];

  final int rows;
  final int columns;
  final PieceSource _nextPiece;

  late List<List<Tetromino?>> _board;
  late ActivePiece _piece;
  int _score = 0;
  int _lines = 0;
  bool _isGameOver = false;

  ActivePiece get piece => _piece;
  int get score => _score;
  int get lines => _lines;
  int get level => _lines ~/ linesPerLevel + 1;
  bool get isGameOver => _isGameOver;
  Duration get dropInterval => dropIntervalFor(level);

  /// 레벨별 낙하 간격. 800ms에서 시작해 100 → 50 → 5ms씩 줄고 150ms에서 멈춘다.
  static Duration dropIntervalFor(int level) {
    var ms = 800;
    for (var l = 1; l < level && ms > 150; l++) {
      if (ms > 300) {
        ms -= 100;
      } else if (ms > 200) {
        ms -= 50;
      } else {
        ms -= 5;
      }
    }
    return Duration(milliseconds: ms);
  }

  /// 화면 표시용 칸 상태(쌓인 블럭 + 떨어지는 블럭). 빈칸은 null.
  List<List<Tetromino?>> get cells {
    final view = [
      for (final row in _board) [...row]
    ];
    for (final (r, c) in _piece.cells) {
      if (r >= 0 && r < rows && c >= 0 && c < columns) view[r][c] = _piece.type;
    }
    return view;
  }

  void reset() {
    _board = List.generate(rows, (_) => List<Tetromino?>.filled(columns, null));
    _score = 0;
    _lines = 0;
    _isGameOver = false;
    _spawn();
  }

  bool moveLeft() => _tryMove(0, -1);

  bool moveRight() => _tryMove(0, 1);

  bool rotate() {
    if (_isGameOver) return false;
    final rotated = rotateClockwise(_piece.shape);
    for (final dCol in _kickOffsets) {
      final candidate =
          ActivePiece(_piece.type, rotated, _piece.row, _piece.col + dCol);
      if (_fits(candidate)) {
        _piece = candidate;
        return true;
      }
    }
    return false;
  }

  /// 한 칸 내린다. 더 못 내려가면 착지시키고 다음 블럭을 꺼낸 뒤 false.
  bool step() {
    if (_isGameOver) return false;
    if (_tryMove(1, 0)) return true;
    _lock();
    _clearLines();
    _spawn();
    return false;
  }

  bool _tryMove(int dRow, int dCol) {
    if (_isGameOver) return false;
    final candidate = _piece.moved(dRow, dCol);
    if (!_fits(candidate)) return false;
    _piece = candidate;
    return true;
  }

  bool _fits(ActivePiece piece) {
    for (final (r, c) in piece.cells) {
      if (r < 0 || r >= rows || c < 0 || c >= columns) return false;
      if (_board[r][c] != null) return false;
    }
    return true;
  }

  void _lock() {
    for (final (r, c) in _piece.cells) {
      _board[r][c] = _piece.type;
    }
  }

  void _clearLines() {
    final remaining = _board.where((row) => row.contains(null)).toList();
    final cleared = rows - remaining.length;
    if (cleared == 0) return;
    _board = [
      for (var i = 0; i < cleared; i++) List<Tetromino?>.filled(columns, null),
      ...remaining,
    ];
    _lines += cleared;
    _score += cleared * pointsPerLine;
  }

  /// 새 블럭을 맨 윗줄 가운데에 놓는다. 놓을 자리가 없으면 게임 오버.
  void _spawn() {
    final type = _nextPiece();
    final width = type.shape[0].length;
    _piece = ActivePiece(type, type.shape, 0, (columns - width) ~/ 2);
    if (!_fits(_piece)) _isGameOver = true;
  }
}
