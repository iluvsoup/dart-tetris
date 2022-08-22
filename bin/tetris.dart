import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:console/console.dart';

int gridSizeX = 20;
int gridSizeY = 20;

int score = 0;

Timer? drawEvent;

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

  Keyboard.bindKeys(controls).listen((key) {
    handleInput(key);
  });
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

void gameOver() {
  drawEvent!.cancel();

  Console.showCursor();
  print('Game over!');

  exit(0);
}

void victory() {
  drawEvent!.cancel();

  Console.showCursor();
  print('You win!');

  exit(0);
}

void handleInput(String key) {
  if (key == '') {
    if (drawEvent != null) {
      drawEvent!.cancel();
    }

    clear();
    Console.showCursor();
    exit(0);
  }
}
