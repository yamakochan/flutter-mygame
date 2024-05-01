import 'dart:math';

//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Paddle Settings
const double kPaddleWidth = 100;
const double kPaddleHeight = 20;
//Start position from bottom.
const double kPaddleStartY = 50;
const Color kPaddleColor = Colors.blue;

//Ball Settings
const double kBallRadius = 10;
const double kBallSpeed = 500;
const double kBallStartYRatio = 1 / 2;
const double kBallMinSpawnAngle = 45;
const double kBallMaxSpawnAngle = 135;
const int kBallRandomNumber = 5;
const double kBallNudgeSpeed = 300;
const double kBallUncontrolledPositionY = 10;
const Color kBallColor = Colors.white;

// Math Settings
const double kRad = pi / 180;

//Button Settings
const double kButtonWidth = 200;
const double kButtonHeight = 50;
const Color kButtonColor = Colors.blue;
const Color kGameOverButtonColor = Colors.red;

//Countdown Settings
const double kCountdownSize = 200;
const TextStyle kCountdownTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 160,
);
const int kCountdownDuration = 3;

//Game Settings
const int kGameTryCount = 3;
const int kBlocksColumnCount = 3;
const int kBlocksRowCount = 5;

//Block Settings
const double kBlocksStartYPosition = 50;
const double kBlocksStartXPosition = 50;
const double kBlocksHeightRatio = 1 / 3;
const List<MaterialColor> kBlockColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.purple,
  Colors.orange,
];
const String kBlockPositionX = 'x';
const String kBlockPositionY = 'y';
const double kBlockPadding = 5;

//FieldLayer Settings
const double kFieldWidth = 5000;
const double kFieldHeight = 5000;
//kFieldColumnLimit = (kFieldWidth / kHexWidth / 0.75).floor()
const int kFieldColumnLimit = 166;
//kFieldRowLimit = (kFieldHeight / kHexHeight).floor() - 1
const int kFieldRowLimit = 124;
const int kFieldColumnOffset = 83;
const int kFieldRowOffset = 62;

//FieldPiece Settings
const double kHexWidth = 40;
const double kHexHeight = 40;

//mappalette Settings
const double kPaletteWidth = 100;
const double kPaletteHeight = 300;

//field Image List
const Map<String, String> kFieldImage = {
  'null': 'hex_null.png',
  'plain': 'hex_plain.png',
  'forest': 'hex_forest.png',
  'hill': 'hex_hill.png',
  'desert': 'hex_desert.png',
  'mountain': 'hex_mountain.png',
  'sea': 'hex_sea.png',
  'road_sn': 'hex_road_sn.png',
  'road_ew': 'hex_road_ew.png',
  'road_se': 'hex_road_se.png',
  'road_sw': 'hex_road_sw.png',
};
const String kBackGroundImage = 'background.png';
