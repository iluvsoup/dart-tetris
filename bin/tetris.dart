import 'dart:io';
import 'dart:async';

import 'package:console/console.dart';

import 'tetrominos/i.dart';
import 'tetrominos/j.dart';
import 'tetrominos/l.dart';
import 'tetrominos/o.dart';
import 'tetrominos/s.dart';
import 'tetrominos/t.dart';
import 'tetrominos/z.dart';

final tetrominos = <String, List<List<List<int>>>>{
  'i': ITetromino().rotations,
  'o': OTetromino().rotations,
  't': TTetromino().rotations,
  'z': ZTetromino().rotations,
  'j': JTetromino().rotations,
  's': STetromino().rotations,
  'l': LTetromino().rotations,
};

const int gridSizeX = 10;
const int gridSizeY = 20;

const bool unicodeTiles = true;

const int gravityInterval = 500; // milliseconds
const int softDropInterval = 250;

Map<int, Map<int, dynamic>> grid = generateGrid();

/*
grid representation:
0 = empty

i: respective tetromino
o: respective tetromino
t: respective tetromino
z: respective tetromino
j: respective tetromino
s: respective tetromino
l: respective tetromino
*/

int score = 0;

int pieceX = 5;
int pieceY = 3;
int pieceRotation = 0;

// late String pieceType;
String pieceType = 't';

bool isSoftDropping = false;

Timer? gravityEvent;

Map canvas = {};

const colors = <String, Color>{
  'i': Color.LIGHT_CYAN,
  'o': Color.YELLOW,
  't': Color.MAGENTA,
  'z': Color.RED,
  'j': Color.DARK_BLUE,
  's': Color.LIME,
  'l': Color.GOLD,
};

const unicodeCharacters = <String, String>{
  'i': '🟦',
  'o': '🟨',
  't': '🟪',
  'z': '🟥',
  'j': '🟫',
  's': '🟩',
  'l': '🟧',
};

const controls = [
  'up',
  'down',
  'left',
  'right',
  'w',
  'a',
  's',
  'd',
  'q',
  'e',
  ' ',
  '', // escape
];

void main() {
  Console.init();
  Keyboard.init();

  Keyboard.echoUnhandledKeys = false;
  Console.hideCursor();

  draw();

  gravityEvent = Timer.periodic(
    Duration(milliseconds: softDropInterval),
    (timer) => gravity,
  );

  Keyboard.bindKeys(controls).listen((key) {
    handleInput(key);
  });
}

Map deepCloneMap(Map map) {
  Map tmp = {};

  map.forEach((k, v) {
    if (v is Map) {
      tmp[k] = deepCloneMap(v);
    } else {
      tmp[k] = v;
    }
  });

  return tmp;
}

Map<int, Map<int, dynamic>> generateGrid() {
  Map<int, Map<int, dynamic>> tmp = {};

  for (int y = 0; y < gridSizeY; y++) {
    tmp[y] = {};
    for (int x = 0; x < gridSizeX; x++) {
      tmp[y]![x] = 0;
    }
  }

  return tmp;
}

void draw() {
  clear();

  canvas = deepCloneMap(grid);

  // overlaying canvas with the falling piece and the preview piece
  final piecePositions = tetrominos[pieceType]![pieceRotation];

  for (var position in piecePositions) {
    canvas[position.last + pieceY]![position.first + pieceX] = pieceType;
  }

  // drawing the canvas
  var pen = TextPen();

  if (unicodeTiles) {
    print('⬛' * (gridSizeX + 2));
  } else {
    pen.setColor(Color.GRAY);
    pen.text('# ' * (gridSizeX + 2));
    pen.print();
    pen.reset();
  }

  for (int y = 0; y < gridSizeY; y++) {
    if (unicodeTiles) {
      pen.text('⬛');
    } else {
      pen.setColor(Color.GRAY);
      pen.text('# ');
    }

    for (int x = 0; x < gridSizeX; x++) {
      var pixel = canvas[y]![x];

      if (unicodeTiles) {
        if (pixel != 0) {
          pen.text(unicodeCharacters[pixel]!);
        } else {
          pen.text('  ');
        }
      } else {
        if (pixel != 0) {
          pen.setColor(colors[pieceType]!);
          pen.text('# ');
        } else {
          pen.text('  ');
        }
      }
    }

    if (unicodeTiles) {
      pen.text('⬛');
    } else {
      pen.setColor(Color.GRAY);
      pen.text('# ');
    }

    pen.print();
    pen.reset();
  }

  if (unicodeTiles) {
    print('⬛' * (gridSizeX + 2));
  } else {
    pen.setColor(Color.GRAY);
    pen.text('# ' * (gridSizeX + 2));
    pen.print();
    pen.reset();
  }
}

void clear() {
  if (Platform.isWindows) {
    stdout.write(
      Process.runSync("cls", [], runInShell: true).stdout,
    );
  } else {
    stdout.write(
      Process.runSync("clear", [], runInShell: true).stdout,
    );
  }
}

void gravity() {
  draw();
}

void gameOver() {
  gravityEvent!.cancel();

  Console.showCursor();
  print('Game over!');

  exit(0);
}

void victory() {
  gravityEvent!.cancel();

  Console.showCursor();
  print('You win!');

  exit(0);
}

// 'up',
// 'down',
// 'left',
// 'right',
// 'w',
// 'a',
// 's',
// 'd',
// 'q',
// 'e',
// ' ',
// '', // escape

void handleInput(String key) {
  if (key == 'left' || key == 'a') {
    pieceX--;
    draw();
  } else if (key == 'right' || key == 'd') {
    pieceX++;
    draw();
  } else if (key == 'q') {
    pieceRotation = (pieceRotation - 1) % 4;
    draw();
  } else if (key == 'e') {
    pieceRotation = (pieceRotation + 1) % 4;
    draw();
  } else if (key == '') {
    if (gravityEvent != null) {
      gravityEvent!.cancel();
    }

    clear();
    Console.showCursor();
    exit(0);
  }
}
