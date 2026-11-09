import 'package:flutter/material.dart';

import 'game_screen.dart';
import 'info_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  /// 배경 그림(307x554)의 가로/세로 비율.
  static const double _backgroundAspectRatio = 307 / 554;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Center(
        // 넓은 화면에서 배경 그림이 가로로 늘어나지 않도록 그림 비율 이상으로는 넓히지 않는다
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: height * _backgroundAspectRatio),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tetrisMenuBackground.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.15),
                    _MenuButton(
                      label: 'Game Start',
                      primary: true,
                      onPressed: () => _push(context, const GameScreen()),
                    ),
                    SizedBox(height: height * 0.05),
                    _MenuButton(
                      label: 'Developer',
                      onPressed: () => _push(context, const InfoScreen()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final style = FilledButton.styleFrom(
      minimumSize: Size((width * 0.5).clamp(200.0, 320.0), 56),
      textStyle: TextStyle(
        fontSize: (width * 0.05).clamp(18.0, 26.0),
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
      elevation: 3,
    );
    final child = Text(label);
    return primary
        ? FilledButton(style: style, onPressed: onPressed, child: child)
        : FilledButton.tonal(style: style, onPressed: onPressed, child: child);
  }
}
