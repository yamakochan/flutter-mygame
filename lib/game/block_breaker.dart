import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/src/camera/camera_component.dart';

import '../constants/constants.dart';
import '../constants/globals.dart';
import 'component/ball.dart';
import 'component/block.dart';
import 'component/countdown_text.dart';
import 'component/map_background.dart';
import 'component/my_text_button.dart';
import 'component/paddle.dart';
import 'component/map_field.dart';

//ゲーム全体をコントロールするメインクラス。FlameGameを継承したクラスを作成。
//mixinは、衝突検知、ドラック検知、タップ検知機能を追加継承
class BlockBreaker extends FlameGame
    with HasCollisionDetection, HasDraggableComponents, HasTappableComponents {
  var fieldList = [];

  @override
  Future<void>? onLoad() async {
    final paddle = Paddle(
      draggingPaddle: draggingPaddle,
    );
    final paddleSize = paddle.size;
    paddle
      ..position.x = size.x / 2 - paddleSize.x / 2 //sizeはゲーム画面のサイズ
      ..position.y = size.y - paddleSize.y - kPaddleStartY;

    //Componentは集約関係（委譲）→parent/child関係を持っている。
    //PositionComponentは描画系Component全ての継承元クラス（親クラス≠parent）
    //以下はPositionComponentをfieldPieceのレイヤ（コンテナ）として使用。

    //cameraがマウスに追従できなかったため、fieldPieceをfollowするのはやめ。
    //（マウスポインタがviewと非連動のためと思料）
    //fieldLayerにFlameGameのフィールドcameraを渡してfieldPieceをcamera.followComponent()に設定する
    //FlameGameにはデフォルトでcameraと対になるworldが作られる

    gviewWidth = size.x;
    gviewHeight = size.y;

    //オブジェクトのanchor.centerのとき、positionが示すcanvas位置がオブジェクトの
    //centerとなるよう表示する。
    //MapBackGroundLayerはコンストラクタでanchor.centerを指定するため、画面サイズの
    //半分をinitX,initY(=position)に指定する。
    //ただし該当オブジェクトの子供はanchorと関わりなく、親のpositionの影響のみを受ける。
    //つまり該当オブジェクトの左上を0.0として配置される。
    gmapBackGround =
        await MapBackGroundLayer.create(initX: size.x / 2, initY: size.y / 2);

    gmapFieldLayer = MapFieldLayer(
        initX: kFieldWidth / 2, initY: kFieldHeight / 2, camera: camera);
    gmapBackGround.add(gmapFieldLayer);

    // fieldButtonのレイヤ。
    final xxpaint = BasicPalette.red.paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    List<Paint> xxpaintLayers = [
      xxpaint,
      BasicPalette.gray.paint(),
    ];
    gfieldPalette = RectangleComponent(
      size: Vector2(kFieldWidth, kHexHeight * 2 + 10), //margin 10(上下5)
      position: Vector2(0, size.y - kHexHeight * 2 - 10),
      anchor: Anchor.topLeft,
      paintLayers: xxpaintLayers,
    );

    gfieldPalette.add(await FieldPiece.create('plain', column: 1, row: 0));
    gfieldPalette.add(await FieldPiece.create('forest', column: 2, row: 0));
    gfieldPalette.add(await FieldPiece.create('hill', column: 2, row: 1));
    gfieldPalette.add(await FieldPiece.create('desert', column: 3, row: 0));
    gfieldPalette.add(await FieldPiece.create('mountain', column: 4, row: 0));
    gfieldPalette.add(await FieldPiece.create('sea', column: 4, row: 1));
    gfieldPalette.add(await FieldPiece.create('road_sn', column: 5, row: 0));
    gfieldPalette.add(await FieldPiece.create('road_ew', column: 6, row: 0));
    gfieldPalette.add(await FieldPiece.create('road_se', column: 6, row: 1));
    gfieldPalette.add(await FieldPiece.create('road_sw', column: 7, row: 0));

    //非同期メソッドの同期呼び出し。
    await addMyTextButton('Start!');

    // gworld.add(gfieldLayer);
    //オブジェクトをゲームに配置する
    await addAll([
      ScreenHitbox(), //画面枠に付与する当たり判定
      paddle,
      gmapBackGround,
      gfieldPalette,
    ]);
    await resetBlocks(); //ブロックの配置処理
  }

  double getSizex() => size.x;
  double getSizey() => size.y;
  Future<void> resetBall() async {
    final ball = Ball();

    ball.position
      ..x = size.x / 2 - ball.size.x / 2
      ..y = size.y * kBallStartYRatio;

    await add(ball);
  }

  Future<void> resetBlocks() async {
    final sizeX = (size.x -
            kBlocksStartXPosition * 2 -
            kBlockPadding * (kBlocksRowCount - 1)) /
        kBlocksRowCount;

    final sizeY = (size.y * kBlocksHeightRatio -
            kBlocksStartYPosition -
            kBlockPadding * (kBlocksColumnCount - 1)) /
        kBlocksColumnCount;

    final blocks = List<Blockxx>.generate(kBlocksColumnCount * kBlocksRowCount,
        (int index) {
      final block = Blockxx(
        blockSize: Vector2(sizeX, sizeY),
      );

      final indexX = index % kBlocksRowCount;
      final indexY = index ~/ kBlocksRowCount;

      block.position
        ..x = kBlocksStartXPosition + indexX * (block.size.x + kBlockPadding)
        ..y = kBlocksStartYPosition + indexY * (block.size.y + kBlockPadding);

      return block;
    });

    await addAll(blocks);
  }

  //Future<void>の非同期メソッド async を記載する。
  Future<void> addMyTextButton(String text) async {
    final myTextButton = MyTextButton(
      text,
      onTapDownMyTextButton: onTapDownMyTextButton,
      renderMyTextButton: renderMyTextButton,
    );

    myTextButton.position
      ..x = size.x / 2 - myTextButton.size.x / 2
      ..y = size.y / 2 - myTextButton.size.y / 2;

    await add(myTextButton);
  }

  void draggingPaddle(DragUpdateEvent event) {
    final paddle = children.whereType<Paddle>().first;

    paddle.position.x += event.delta.x;

    if (paddle.position.x < 0) {
      paddle.position.x = 0;
    }
    if (paddle.position.x > size.x - paddle.size.x) {
      paddle.position.x = size.x - paddle.size.x;
    }
  }

  Future<void> onTapDownMyTextButton() async {
    children.whereType<MyTextButton>().forEach((button) {
      button.removeFromParent();
    });
    await countdown();
    await resetBall();
  }

  void renderMyTextButton(Canvas canvas) {
    final myTextButton = children.whereType<MyTextButton>().first;
    final rect = Rect.fromLTWH(
      0,
      0,
      myTextButton.size.x,
      myTextButton.size.y,
    );
    final bgPaint = Paint()..color = kButtonColor;
    canvas.drawRect(rect, bgPaint);
  }

  Future<void> countdown() async {
    for (var i = kCountdownDuration; i > 0; i--) {
      final countdownText = CountdownText(count: i);

      countdownText.position
        ..x = size.x / 2 - countdownText.size.x / 2
        ..y = size.y / 2 - countdownText.size.y / 2;

      await add(countdownText);

      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }
}
