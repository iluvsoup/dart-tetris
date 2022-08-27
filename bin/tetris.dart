import 'dart:io';
import 'dart:async';
// import 'dart:math';

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

int gridSizeX = 10;
int gridSizeY = 20;

final grid = generateGrid();

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

bool unicodeTiles = false;

int score = 0;

int pieceX = 0;
int pieceY = 0;
int pieceRotation = 0;

late String pieceType;

bool isSoftDropping = false;

int gravityInterval = 500; // milliseconds
int softDropInterval = 250;

Timer? gravityEvent;

List<List<dynamic>> canvas = [];

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

  gravityEvent = Timer.periodic(
    Duration(milliseconds: softDropInterval),
    (timer) => gravity,
  );

  Keyboard.bindKeys(controls).listen((key) {
    handleInput(key);
  });
}

List<List<dynamic>> generateGrid() {
  List<List<dynamic>> tmp = [];

  for (int y = 0; y < gridSizeY; y++) {
    tmp[y] = [];
    for (int x = 0; x < gridSizeX; x++) {
      tmp[y][x] = 0;
    }
  }

  return tmp;
}

void draw() {
  clear();
  canvas = grid;

  final piecePositions = tetrominos[pieceType]![pieceRotation];
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

void handleInput(String key) {
  if (key == '') {
    if (gravityEvent != null) {
      gravityEvent!.cancel();
    }

    clear();
    Console.showCursor();
    exit(0);
  }
}
