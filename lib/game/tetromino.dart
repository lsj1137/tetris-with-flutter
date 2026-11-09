import 'dart:math';

/// 블럭 모양. 1 = 칸 있음, 0 = 빈칸.
typedef Shape = List<List<int>>;

/// 테트로미노 7종.
enum Tetromino {
  o([
    [1, 1], // ㅁ
    [1, 1],
  ]),
  i([
    [1, 1, 1, 1], // ㅡ
  ]),
  j([
    [1, 1, 1], // ㄱ
    [0, 0, 1],
  ]),
  l([
    [1, 1, 1], // flip ㄱ
    [1, 0, 0],
  ]),
  t([
    [1, 1, 1], // ㅜ
    [0, 1, 0],
  ]),
  z([
    [1, 1, 0], // ㄹ
    [0, 1, 1],
  ]),
  s([
    [0, 1, 1], // flip ㄹ
    [1, 1, 0],
  ]);

  const Tetromino(this.shape);

  final Shape shape;
}

/// 시계 방향 90도 회전한 새 모양을 돌려준다.
Shape rotateClockwise(Shape shape) {
  final height = shape.length;
  final width = shape[0].length;
  return List.generate(
    width,
    (r) => List.generate(height, (c) => shape[height - 1 - c][r]),
  );
}

/// 7종을 한 묶음으로 섞어 차례로 꺼낸다(같은 블럭만 연달아 나오는 것 방지).
class SevenBag {
  SevenBag([Random? random]) : _random = random ?? Random();

  final Random _random;
  final List<Tetromino> _bag = [];

  Tetromino next() {
    if (_bag.isEmpty) {
      _bag
        ..addAll(Tetromino.values)
        ..shuffle(_random);
    }
    return _bag.removeLast();
  }
}
