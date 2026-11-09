import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/game/tetris_engine.dart';
import 'package:tetris/game/tetromino.dart';
import 'package:tetris/main.dart';
import 'package:tetris/screens/game_screen.dart';

void main() {
  testWidgets('메뉴에서 게임으로 들어가고 나올 수 있다', (tester) async {
    await tester.pumpWidget(const TetrisApp());
    expect(find.text('Game Start'), findsOneWidget);
    expect(find.text('Developer'), findsOneWidget);

    await tester.tap(find.text('Game Start'));
    await tester.pumpAndSettle();
    expect(find.text('TETRIS'), findsOneWidget);
    expect(find.text('LEVEL'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.exit_to_app));
    await tester.pumpAndSettle();
    expect(find.text('Game Start'), findsOneWidget);
  });

  testWidgets('개발자 정보 화면', (tester) async {
    await tester.pumpWidget(const TetrisApp());
    await tester.tap(find.text('Developer'));
    await tester.pumpAndSettle();
    expect(find.text('SeJun Lim'), findsOneWidget);
  });

  testWidgets('키보드와 타이머로 블럭이 움직인다', (tester) async {
    final engine = TetrisEngine(nextPiece: () => Tetromino.o);
    await tester.pumpWidget(MaterialApp(home: GameScreen(engine: engine)));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    expect(engine.piece.col, 3);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(engine.piece.col, 5);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(engine.piece.row, 1);

    await tester.pump(const Duration(milliseconds: 800));
    expect(engine.piece.row, 2);

    await tester.pumpWidget(const SizedBox()); // 타이머 해제 확인
  });

  testWidgets('게임 오버 후 다시 하기', (tester) async {
    final engine = TetrisEngine(nextPiece: () => Tetromino.o);
    await tester.pumpWidget(MaterialApp(home: GameScreen(engine: engine)));
    // O 10개가 4~5열에 쌓이면 끝난다(블럭당 최대 19칸 낙하)
    for (var i = 0; i < 200 && !engine.isGameOver; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    }
    await tester.pumpAndSettle();
    expect(find.text('Game Over'), findsOneWidget);

    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();
    expect(engine.isGameOver, isFalse);
    expect(find.text('LEVEL'), findsOneWidget);
    expect(engine.score, 0);

    await tester.pumpWidget(const SizedBox());
  });
}
