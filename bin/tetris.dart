import 'dart:io';
import 'dart:async';
import 'dart:math';

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
const int softDropInterval = 50;

const double gravityFrames = (gravityInterval / softDropInterval);

int frame = 0;

Map<int, Map<int, dynamic>> grid = generateGrid();

int score = 0;

int pieceX = 4;
int pieceY = -2;
int pieceRotation = 0;

Random rng = Random();

late Map<int, dynamic> emptyLine;

List<String> pieceTypes = ['i', 'o', 't', 'z', 'j', 's', 'l'];
late String pieceType;

bool isSoftDropping = false;

int landingFrames = 1; // amount of frames that pass after touching the ground before piece officially lands
int framesSincePieceLanded = 0;

late Timer gravityEvent;

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

const controls = ['up', 'down', 'left', 'right', 'z', 'w', 'a', 's', 'd', ' ', ''];

void main() {
  Console.init();
  Keyboard.init();

  Keyboard.echoUnhandledKeys = false;
  Console.hideCursor();

  pieceType = pieceTypes.elementAt(rng.nextInt(pieceTypes.length));

  emptyLine = {};
  for (int i = 0; i < gridSizeX; i++) {
    emptyLine[i] = 0;
  }

  gravityEvent = Timer.periodic(
    Duration(milliseconds: softDropInterval),
    (timer) => gravity(),
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

bool isPieceColliding(String type, int rotation, int x, int y) {
  final positions = tetrominos[type]![rotation];

  for (var position in positions) {
    int realX = position.first + x;
    int realY = position.last + y;

    if (realX < 0 || realX >= gridSizeX || realY >= gridSizeY) return true;

    if (grid[realY] != null && grid[realY]![realX] != 0) return true;
  }

  return false;
}

void draw() {
  clear();

  canvas = deepCloneMap(grid);

  // overlaying canvas with the falling piece and the preview piece
  final piecePositions = tetrominos[pieceType]![pieceRotation];

  for (int previewY = pieceY; previewY < gridSizeY; previewY++) {
    if (isPieceColliding(pieceType, pieceRotation, pieceX, previewY + 1)) {
      for (var position in piecePositions) {
        canvas[position.last + previewY]![position.first + pieceX] = 1;
      }

      break;
    }
  }

  for (var position in piecePositions) {
    if (canvas[position.last + pieceY] != null) {
      canvas[position.last + pieceY]![position.first + pieceX] = pieceType;
    }
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

      if (pixel == 0 || pixel == 1) {
        if (pixel == 0) {
          pen.text('  ');
        } else {
          pen.setColor(Color.LIGHT_GRAY);
          if (unicodeTiles) {
            pen.text('⬜');
          } else {
            pen.text('# ');
          }
        }
      } else {
        pen.setColor(colors[pixel]!);
        if (unicodeTiles) {
          pen.text(unicodeCharacters[pixel]!);
        } else {
          pen.text('# ');
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

  print('\nScore: $score');
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
  if (isSoftDropping || (!isSoftDropping && frame % gravityFrames == 0)) {
    if (isPieceColliding(pieceType, pieceRotation, pieceX, pieceY + 1)) {
      if (framesSincePieceLanded == landingFrames) {
        framesSincePieceLanded = 0;
        placePiece(pieceY);
      } else if (frame % gravityFrames == 0) {
        framesSincePieceLanded++;
      }
    } else {
      pieceY++;
    }

    draw();

    if (frame % gravityFrames == 0) {
      isSoftDropping = false;
    }
  }

  frame++;
}

void gameOver() {
  gravityEvent.cancel();

  Console.showCursor();
  print('Game over!');

  exit(0);
}

void placePiece(y) {
  final piecePositions = tetrominos[pieceType]![pieceRotation];

  for (var position in piecePositions) {
    grid[position.last + y]![position.first + pieceX] = pieceType;
  }

  pieceType = pieceTypes.elementAt(rng.nextInt(pieceTypes.length));

  pieceY = -2;
  pieceX = 4;
  pieceRotation = 0;

  clearLines();
}

void clearLines() {
  score++;
  for (int y = 0; y < gridSizeY; y++) {
    var line = grid[y];

    bool isLineHollow = false; // (hollow as in not full)

    for (int x = 0; x < gridSizeX; x++) {
      if (line![x] == 0) {
        isLineHollow = true;
        break;
      }
    }

    if (!isLineHollow) {
      grid[y] = emptyLine;
    }
  }
}

void handleInput(String key) {
  int numberOfPieceRotations = tetrominos[pieceType]!.length;

  if (key == 'left' || key == 'a') {
    if (!isPieceColliding(pieceType, pieceRotation, pieceX - 1, pieceY)) {
      pieceX--;
    }
  } else if (key == 'right' || key == 'd') {
    if (!isPieceColliding(pieceType, pieceRotation, pieceX + 1, pieceY)) {
      pieceX++;
    }
  } else if (key == 'up' || key == 'w') {
    int nextRotation = (pieceRotation + 1) % numberOfPieceRotations;
    if (!isPieceColliding(pieceType, nextRotation, pieceX, pieceY)) {
      pieceRotation = nextRotation;
    }
  } else if (key == 'z') {
    int nextRotation = (pieceRotation - 1) % numberOfPieceRotations;
    if (!isPieceColliding(pieceType, nextRotation, pieceX, pieceY)) {
      pieceRotation = nextRotation;
    }
  } else if (key == 'down' || key == 's') {
    isSoftDropping = true;
  } else if (key == ' ') {
    for (int nextPieceY = pieceY; nextPieceY < gridSizeY; nextPieceY++) {
      if (isPieceColliding(pieceType, pieceRotation, pieceX, nextPieceY + 1)) {
        placePiece(nextPieceY);
        break;
      }
    }
  } else if (key == '') {
    gravityEvent.cancel();

    clear();
    Console.showCursor();
    exit(0);
  }

  draw();
}
