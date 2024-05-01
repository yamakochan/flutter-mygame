import 'dart:html';
import 'dart:ui';
import 'dart:math';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
//import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/animation.dart';

import '../../constants/constants.dart';
import '../../constants/globals.dart';

class MapBackGroundLayer extends PositionComponent
    with TapCallbacks, HasGameRef {
  MapBackGroundLayer({initX = 0, initY = 0})
      : super(
          size: Vector2(kFieldWidth, kFieldHeight),
          position: Vector2(initX, initY),
          anchor: Anchor.center,
          scale: Vector2(1.0, 1.0),
        );

  //コンストラクタでFuture型を返せない（非同期関数として定義できない）ため、
  //初期化処理中のimageloadを待てない。このため
  //１．imageloadを伴う初期化処理を専用メソッドに分離
  //２．コンストラクタ代わりのstaticメソッドを非同期関数として定義し、
  // 　　中でコンストラクタ及び上記１．をcallし、インスタンスをリターンする。
  //これにより、imageloadを待ち合わせることが可能。
  static Future<MapBackGroundLayer> create({initX = 0, initY = 0}) async {
    MapBackGroundLayer mapmap = MapBackGroundLayer(initX: initX, initY: initY);
    await mapmap.initMapBackGroundLayer();
    return mapmap;
  }

  Future<void> initMapBackGroundLayer() async {
    final xxpaint = BasicPalette.red.paint()..style = PaintingStyle.stroke;
    final imagesLoader = Images();
    //非同期処理（load）は処理が未来に完了を表すFuture<T>型の結果を返す。
    Future<Image> image = imagesLoader.load(kBackGroundImage);
    Future<SpriteComponent> backGroundSprite =
        //thenメソッドを使って、非同期処理終了後のコールバック関数を登録
        //イメージload後に戻り値<Image>を引数にSpriteComponentインスタンスを作成
        //Future<Image>を待つので、このSpriteComponentもfutureになる。
        image.then((Image i) => SpriteComponent(
              sprite: Sprite(i),
              size: Vector2(kFieldWidth, kFieldHeight),
              scale: Vector2(1.0, 1.0),
              position: Vector2.all(0),
              anchor: Anchor.topLeft,
              paint: xxpaint,
            ));
    //SpriteComponentインスタンス作成後、this.add(this省略)でto be added as a child to this component
    await backGroundSprite.then((SpriteComponent bgi) => add(bgi));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!event.handled) {
      //canvasPositionで画面左上を0,0としたマウス座標を取得
      final tapOffset = Vector2(event.canvasPosition.x - gviewWidth / 2,
          event.canvasPosition.y - gviewHeight / 2);
      // gmapFieldLayer.tempArea.position =
      //     gmapFieldLayer.tempArea.position + tapOffset;
      final tempVector2 = gmapFieldLayer.tempArea.position + tapOffset;
      final effect2 = MoveEffect.to(
          tempVector2, EffectController(duration: 1, curve: Curves.decelerate));
      gmapFieldLayer.tempArea.add(effect2);
      final tempVector = position - tapOffset;
      final effect = MoveEffect.to(
          tempVector, EffectController(duration: 1, curve: Curves.decelerate));
      add(effect);
    }
    super.onTapDown(event);
  }
}
