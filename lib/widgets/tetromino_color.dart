import 'package:flutter/material.dart';

import '../game/tetromino.dart';

extension TetrominoColor on Tetromino {
  Color get color => switch (this) {
        Tetromino.i => Colors.cyan,
        Tetromino.o => Colors.yellow,
        Tetromino.t => Colors.purple,
        Tetromino.s => Colors.green,
        Tetromino.z => Colors.red,
        Tetromino.l => Colors.orange,
        Tetromino.j => Colors.blue,
      };
}
