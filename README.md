# in progress

# Command line Tetris in Dart
A small project I made in response to my sudden obsession with command line games

# TODO
- Stop soft dropping when piece lands
- Fix annoying problem in which you stop soft dropping for a single frame because of how holding down keys works in the package I use
- Maybe switch to another package that has better keyboard support

## Requirements
Dart

## Getting started
Install required packages with
```bash
dart pub get
```

## Compile with
```bash
dart compile jit-snapshot bin/tetris.dart -o dist/tetris.jit
```
or 
```bash
dart compile aot-snapshot bin/tetris.dart -o dist/tetris.aot
```

## Run with
```bash
dart run
```
or
```bash
dart run dist/tetris.jit
```
or
```bash
dartaotruntime dist/tetris.aot
```

This might not work on windows, I can't say for sure because I don't use windows