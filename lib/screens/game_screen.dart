import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/tetris_engine.dart';
import '../widgets/board_view.dart';
import '../widgets/control_button.dart';
import '../widgets/stat_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.engine});

  /// 테스트에서 블럭 순서를 고정할 때 주입한다.
  final TetrisEngine? engine;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const double _maxContentWidth = 720;

  late final TetrisEngine _engine = widget.engine ?? TetrisEngine();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 현재 레벨 속도로 낙하 타이머를 (다시) 건다.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_engine.dropInterval, (_) => _apply(_engine.step));
  }

  /// 조작 하나를 반영하고, 레벨이 바뀌면 속도를, 게임이 끝나면 결과창을 처리한다.
  void _apply(void Function() action) {
    if (_engine.isGameOver) return;
    final levelBefore = _engine.level;
    setState(action);
    if (_engine.isGameOver) {
      _timer?.cancel();
      _showGameOver();
    } else if (_engine.level != levelBefore) {
      _startTimer();
    }
  }

  void _moveLeft() => _apply(_engine.moveLeft);
  void _moveRight() => _apply(_engine.moveRight);
  void _rotate() => _apply(_engine.rotate);
  void _drop() => _apply(_engine.step);

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final isDown = event is KeyDownEvent;
    final isRepeat = event is KeyRepeatEvent;
    if (!isDown && !isRepeat) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.space) {
      if (isDown) _rotate(); // 꾹 누르고 있을 때 계속 도는 것 방지
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _drop();
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _moveLeft();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _moveRight();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  Future<void> _showGameOver() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: ${_engine.score}'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(_engine.reset);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = SizedBox(height: size.height * 0.02);

    return Scaffold(
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: _onKey,
          child: Center(
            // 넓은 화면에서 조작 버튼이 양 끝으로 벌어지지 않도록 폭을 제한한다
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Row(
                children: [
                  // 화면 왼쪽: 나가기 + 왼쪽 이동
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: IconButton(
                                icon: const Icon(Icons.exit_to_app),
                                tooltip: 'Exit',
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ControlButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            tooltip: 'Move left',
                            onPressed: _moveLeft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 가운데: 제목 + 판 + 회전/점수/내리기
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        gap,
                        Text(
                          'TETRIS',
                          style: TextStyle(
                            fontSize: (size.width * 0.07).clamp(24.0, 40.0),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        gap,
                        Expanded(
                          child: Center(child: BoardView(cells: _engine.cells)),
                        ),
                        gap,
                        Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.03),
                          child: Row(
                            children: [
                              Expanded(
                                child: ControlButton(
                                  icon: Icons.rotate_right_rounded,
                                  tooltip: 'Rotate',
                                  onPressed: _rotate,
                                ),
                              ),
                              StatCard(
                                  level: _engine.level, score: _engine.score),
                              Expanded(
                                child: ControlButton(
                                  icon: Icons.keyboard_arrow_down_rounded,
                                  tooltip: 'Move down',
                                  onPressed: _drop,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 화면 오른쪽: 오른쪽 이동
                  Expanded(
                    child: Column(
                      children: [
                        const Spacer(),
                        Expanded(
                          child: ControlButton(
                            icon: Icons.arrow_forward_ios_rounded,
                            tooltip: 'Move right',
                            onPressed: _moveRight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
