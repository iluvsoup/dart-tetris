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

int pieceX = 4;
int pieceY = 2;
int pieceRotation = 0;

// late String pieceType;
String pieceType = 't';

bool isSoftDropping = false;

Timer gravityEvent = Timer.periodic(
  Duration(milliseconds: softDropInterval),
  (timer) => gravity,
);

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

const controls = ['up', 'down', 'left', 'right', 'z', 'w', 'a', 's', ' ', ''];

void main() {
  Console.init();
  Keyboard.init();

  Keyboard.echoUnhandledKeys = false;
  Console.hideCursor();

  draw();

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

  for (int y = 0; y < gridSizeY; y++) {
    pen.setColor(Color.GRAY);

    if (unicodeTiles) {
      pen.text('⬛');
    } else {
      pen.text('# ');
    }

    for (int x = 0; x < gridSizeX; x++) {
      var pixel = canvas[y]![x];

      pen.setColor(colors[pieceType]!);

      if (unicodeTiles) {
        if (pixel != 0) {
          pen.text(unicodeCharacters[pixel]!);
        } else {
          pen.text('⬛');
        }
      } else {
        if (pixel != 0) {
          pen.text('# ');
        } else {
          pen.text('  ');
        }
      }
    }

    pen.setColor(Color.GRAY);

    if (unicodeTiles) {
      pen.text('⬛');
    } else {
      pen.text('# ');
    }

    pen.print();
    pen.reset();
  }

  pen.setColor(Color.GRAY);

  if (unicodeTiles) {
    pen.text('⬛' * (gridSizeX + 2));
  } else {
    pen.text('# ' * (gridSizeX + 2));
  }

  pen.print();
  pen.reset();
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
  gravityEvent.cancel();

  Console.showCursor();
  print('Game over!');

  exit(0);
}

void victory() {
  gravityEvent.cancel();

  Console.showCursor();
  print('You win!');

  exit(0);
}

void handleInput(String key) {
  int numberOfPieceRotations = tetrominos[pieceType]!.length;

  if (key == 'left' || key == 'a') {
    pieceX--;
  } else if (key == 'right' || key == 'd') {
    pieceX++;
  } else if (key == 'up' || key == 'w') {
    pieceRotation = (pieceRotation + 1) % numberOfPieceRotations;
  } else if (key == 'z') {
    pieceRotation = (pieceRotation - 1) % numberOfPieceRotations;
  } else if (key == 'down' || key == 's') {
    // soft drop
  } else if (key == ' ') {
    // hard drop
  } else if (key == '') {
    gravityEvent.cancel();

    clear();
    Console.showCursor();
    exit(0);
  }

  draw();
}
