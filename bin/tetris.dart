import 'dart:io';
import 'dart:async';
// import 'dart:math';

import 'package:console/console.dart';

import 'tetrominos/tetrominos.dart';

final tetrominos = Tetrominos();

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

int score = 0;

int pieceX = 0;
int pieceY = 0;
int pieceRotation = 0;

int gravityInterval = 500; // milliseconds
int softDropInterval = 250;

Timer? gravityEvent;

const colors = <String, Color>{
  'i': Color.LIGHT_CYAN,
  'o': Color.YELLOW,
  't': Color.MAGENTA,
  'z': Color.RED,
  'j': Color.DARK_BLUE,
  's': Color.LIME,
  'l': Color.GOLD,
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

void gravity() {}

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
