import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/game/tetris_engine.dart';
import 'package:tetris/game/tetromino.dart';

TetrisEngine engineOf(Tetromino type) => TetrisEngine(nextPiece: () => type);

/// 착지할 때까지 내린다.
void dropToBottom(TetrisEngine engine) {
  while (engine.step()) {}
}

Set<(int, int)> cellsOf(TetrisEngine engine) => engine.piece.cells.toSet();

void main() {
  group('spawn', () {
    test('I 블럭은 맨 윗줄 가운데에 나온다', () {
      final engine = engineOf(Tetromino.i);
      expect(cellsOf(engine), {(0, 3), (0, 4), (0, 5), (0, 6)});
      expect(engine.isGameOver, isFalse);
    });

    test('O 블럭은 4~5열에 나온다', () {
      expect(cellsOf(engineOf(Tetromino.o)), {(0, 4), (0, 5), (1, 4), (1, 5)});
    });
  });

  group('move', () {
    test('벽에서 더 못 나간다', () {
      final engine = engineOf(Tetromino.o);
      while (engine.moveLeft()) {}
      expect(engine.piece.col, 0);
      while (engine.moveRight()) {}
      expect(engine.piece.col, 8);
    });

    test('쌓인 블럭을 뚫고 옆으로 못 간다', () {
      final engine = engineOf(Tetromino.o);
      for (var i = 0; i < 2; i++) {
        while (engine.moveLeft()) {}
        dropToBottom(engine); // 0~1열에 O 두 개(16~19행)
      }
      // 새 O를 바닥(18~19행)까지 내린 뒤 왼쪽으로 밀면 2열에서 멈춰야 한다
      for (var i = 0; i < 18; i++) {
        expect(engine.step(), isTrue);
      }
      while (engine.moveLeft()) {}
      expect(engine.piece.col, 2);
    });
  });

  group('rotate', () {
    test('I 블럭 회전 시 세로가 된다', () {
      final engine = engineOf(Tetromino.i);
      engine.step();
      expect(engine.rotate(), isTrue);
      expect(engine.piece.shape.length, 4);
      expect(engine.piece.shape[0].length, 1);
    });

    test('오른쪽 벽에 붙은 세로 I도 밀어서 회전된다', () {
      final engine = engineOf(Tetromino.i);
      engine.step();
      engine.rotate();
      while (engine.moveRight()) {}
      expect(engine.piece.col, 9);
      expect(engine.rotate(), isTrue);
      for (final (r, c) in engine.piece.cells) {
        expect(r, inInclusiveRange(0, 19));
        expect(c, inInclusiveRange(0, 9));
      }
    });

    test('rotateClockwise 4번이면 원래 모양', () {
      for (final type in Tetromino.values) {
        var shape = type.shape;
        for (var i = 0; i < 4; i++) {
          shape = rotateClockwise(shape);
        }
        expect(shape, type.shape, reason: type.name);
      }
    });

    test('회전해도 쌓인 블럭이 지워지지 않는다', () {
      final engine = engineOf(Tetromino.o);
      dropToBottom(engine);
      final before =
          engine.cells.expand((r) => r).where((c) => c != null).length;
      engine.rotate();
      final after =
          engine.cells.expand((r) => r).where((c) => c != null).length;
      expect(after, before);
    });
  });

  group('lock & clear', () {
    test('바닥에 닿으면 굳고 다음 블럭이 나온다', () {
      final engine = engineOf(Tetromino.o);
      dropToBottom(engine);
      expect(engine.cells[19][4], Tetromino.o);
      expect(engine.piece.row, 0);
    });

    test('O 5개로 두 줄을 지우면 점수 20, 판이 비워진다', () {
      final engine = engineOf(Tetromino.o);
      for (final targetCol in [0, 2, 4, 6, 8]) {
        while (engine.piece.col > targetCol) {
          engine.moveLeft();
        }
        while (engine.piece.col < targetCol) {
          engine.moveRight();
        }
        dropToBottom(engine);
      }
      expect(engine.lines, 2);
      expect(engine.score, 20);
      expect(engine.cells[19].every((c) => c == null), isTrue);
      expect(engine.cells[18].every((c) => c == null), isTrue);
    });

    test('3줄마다 레벨이 오른다', () {
      final engine = engineOf(Tetromino.o);
      void clearTwoLines() {
        for (final targetCol in [0, 2, 4, 6, 8]) {
          while (engine.piece.col > targetCol) {
            engine.moveLeft();
          }
          while (engine.piece.col < targetCol) {
            engine.moveRight();
          }
          dropToBottom(engine);
        }
      }

      clearTwoLines();
      expect(engine.level, 1);
      clearTwoLines();
      expect(engine.lines, 4);
      expect(engine.level, 2);
    });
  });

  group('game over', () {
    test('같은 자리에 계속 쌓으면 게임 오버, 이후 조작은 무시된다', () {
      final engine = engineOf(Tetromino.o);
      for (var i = 0; i < 10; i++) {
        dropToBottom(engine);
      }
      expect(engine.isGameOver, isTrue);
      expect(engine.moveLeft(), isFalse);
      expect(engine.rotate(), isFalse);
      expect(engine.step(), isFalse);
    });

    test('reset 하면 판·점수가 초기화된다', () {
      final engine = engineOf(Tetromino.o);
      for (var i = 0; i < 10; i++) {
        dropToBottom(engine);
      }
      engine.reset();
      expect(engine.isGameOver, isFalse);
      expect(engine.score, 0);
      expect(engine.level, 1);
      expect(engine.cells[19].every((c) => c == null), isTrue);
    });
  });

  test('낙하 간격은 원래 규칙(800→…→150ms)을 따른다', () {
    int ms(int level) => TetrisEngine.dropIntervalFor(level).inMilliseconds;
    expect(ms(1), 800);
    expect(ms(2), 700);
    expect(ms(6), 300);
    expect(ms(7), 250);
    expect(ms(8), 200);
    expect(ms(9), 195);
    expect(ms(18), 150);
    expect(ms(100), 150);
  });

  test('SevenBag은 7개마다 7종을 한 번씩 낸다', () {
    final bag = SevenBag(Random(42));
    for (var round = 0; round < 3; round++) {
      final drawn = {for (var i = 0; i < 7; i++) bag.next()};
      expect(drawn, Tetromino.values.toSet());
    }
  });
}
