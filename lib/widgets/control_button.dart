import 'package:flutter/material.dart';

/// 게임 조작용 원형 아이콘 버튼.
class ControlButton extends StatelessWidget {
  const ControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final diameter = (MediaQuery.sizeOf(context).width * 0.1).clamp(48.0, 72.0);
    return Center(
      child: IconButton.filledTonal(
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: diameter * 0.45,
        style: IconButton.styleFrom(fixedSize: Size.square(diameter)),
        icon: Icon(icon),
      ),
    );
  }
}
