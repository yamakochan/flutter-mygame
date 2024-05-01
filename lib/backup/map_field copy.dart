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

import '../constants/constants.dart';
import '../constants/globals.dart';

//MapFieldLayerの初期ポジションは画面左上。Anchor.topLeft
class MapFieldLayer extends PositionComponent {
  MapFieldLayer({initX = 0, initY = 0, required this.camera})
      : super(
          size: Vector2(kFieldWidth, kFieldHeight),
          position: Vector2(initX, initY),
          anchor: Anchor.topLeft, //offset x:-kFieldWidth y:-kFieldHeight
          scale: Vector2(1.0, 1.0),
        ) {
    add(mainArea);
    add(tempArea);
  }
  late List<FieldPiece> tempPieceList = [];
  //2次元配列[c][r]初期値はfieldTypeがnullのfieldpiece
  late List<List<FieldPiece>> pieceList = List.generate(kFieldColumnLimit,
      (_) => List.generate(kFieldRowLimit, (_) => FieldPiece('null')));
  PositionComponent tempArea = PositionComponent(
    size: Vector2(0, 0),
    position: Vector2(0, 0),
    anchor: Anchor.topLeft, //offset x:-kFieldWidth y:-kFieldHeight
    scale: Vector2(1.0, 1.0),
  );
  PositionComponent mainArea = PositionComponent(
    size: Vector2(0, 0),
    position: Vector2(0, 0),
    anchor: Anchor.topLeft, //offset x:-kFieldWidth y:-kFieldHeight
    scale: Vector2(1.0, 1.0),
  );
  Camera camera; //FlameGameのフィールドの参照を保有
}

class FieldPiece extends PositionComponent {
  //コンストラクタ内でイメージロード実施。非同期で
  //コンストラクタはasync関数にできない。
  FieldPiece(this.fieldType,
      {initX = 0,
      initY = 0,
      this.tempMode = false,
      this.column = 0,
      this.row = 0})
      : super(
          size: Vector2(0, 0),
          position: Vector2(initX, initY), //デフォルトはgmapFieldLayerの真ん中に配置
          anchor: Anchor.center,
          scale: Vector2(1.0, 1.0),
        ) {
    //image sprite
    final xxpaint = BasicPalette.red.paint()..style = PaintingStyle.stroke;
    final imagesLoader = Images();
    //非同期処理（load）は処理が未来に完了を表すFuture<T>型の結果を返す。
    Future<Image> image =
        imagesLoader.load(kFieldImage[fieldType] ?? 'hex_null.png');
    Future<SpriteComponent> fieldSprite =
        //thenメソッドを使って、非同期処理終了後のコールバック関数を登録
        //イメージload後に戻り値<Image>を引数にSpriteComponentインスタンスを作成
        //Future<Image>を待つので、このSpriteComponentもfutureになる。
        image.then((Image i) => SpriteComponent(
              sprite: Sprite(i),
              size: Vector2(kHexWidth, kHexHeight),
              scale: Vector2(1.0, 1.0),
              position: Vector2.all(0),
              anchor: Anchor.center,
              paint: xxpaint,
            ));
    //SpriteComponentインスタンス作成後、this.add(this省略)でto be added as a child to this component
    fieldSprite.then((SpriteComponent fie) => add(fie));

    //HEX geometry
    final List<Vector2> fieldVerticesList = ([
      Vector2(0.0, -1 * kHexHeight / 2),
      Vector2(-1 * kHexWidth / 2, -1 * kHexHeight / 4),
      Vector2(-1 * kHexWidth / 2, kHexHeight / 4),
      Vector2(0.0, kHexHeight / 2),
      Vector2(kHexWidth / 2, kHexHeight / 4),
      Vector2(kHexWidth / 2, -1 * kHexHeight / 4),
    ]);

    //tempAreaの場合のみ影付きで生成
    if (tempMode) {
      final xxshadow = BasicPalette.black.paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
      add(PolygonComponent(
        fieldVerticesList,
        position: Vector2(-1.0, 1.0),
        scale: Vector2(1.0, 1.0),
        paint: xxshadow,
        angle: pi / 2,
        anchor: Anchor.center,
      ));
    }

    //2Dオブジェクトのpositionの基点。defaultはTopLeft。center=Anchor(0.5, 0.5)
    const Anchor hexAnchor = Anchor.center;
    final FieldPieceHEX fieldHEX = FieldPieceHEX(
      fieldPiece: this,
      fieldVerticesList: fieldVerticesList,
      hexAnchor: hexAnchor,
      xxpaint: xxpaint,
    );
    add(fieldHEX);
  }

  //フィールド（クラスのプロパティ）はグローバル変数であり型を明示する。
  //_で始まる名称にすると、ライブラリローカルのフィールド、メソッドになる。
  //なお、関数内などブロック内の変数はブロックローカルであり、_を付けても意味ない。
  final String fieldType;
  int column;
  int row;
  late bool tempMode; //生成後初回移動か否かを判定するフラグ。map画面のtempListからpieceをremoveするために使用。

  @override
  Future<void> onLoad() async {
    return super.onLoad();
  }
}

//mixin DragCallbacks：クラスのメソッドを使えるように。
//mixin HasGameRef：ゲームループのプロパティやメソッドを参照
class FieldPieceHEX extends PolygonComponent
    with DragCallbacks, TapCallbacks, HasGameRef {
  FieldPieceHEX(
      {required this.fieldPiece,
      required this.fieldVerticesList,
      required this.hexAnchor,
      required this.xxpaint})
      : super(
          fieldVerticesList,
          position: Vector2.all(0),
          scale: Vector2(1.0, 1.0),
          paint: xxpaint,
          angle: pi / 2,
          anchor: hexAnchor,
        );

  final FieldPiece fieldPiece;
  final List<Vector2> fieldVerticesList;
  final Anchor hexAnchor;
  final Paint xxpaint;

  @override
  Future<void> onLoad() async {
    return super.onLoad();
  }

  //空のメソッドでも重なったオブジェクトと同じイベント処理メソッドを置くことで
  //イベントの伝播をストップできる。下のオブジェクトにイベントを伝播したい場合
  //はevent.continuePropagation to true
  @override
  void onTapDown(TapDownEvent event) {
    if (!event.handled) {}
    super.onTapDown(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    fieldPiece.priority = 99; //drag中に最前面に描画するため。（defaultは1）
    super.onDragStart(event);
    // fieldPieceをカメラの追跡対象に指定。..マウスだとうまくいかない。没。
    // gmapFieldLayer.camera.followComponent(fieldPiece);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    draggingField(event);
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    fieldPiece.priority = 0;
    if (fieldPiece.tempMode) {
      gmapFieldLayer.tempArea.remove(fieldPiece);
      gmapFieldLayer.tempPieceList.remove(fieldPiece);
      fieldPiece.position.x += gmapFieldLayer.tempArea.position.x;
      fieldPiece.position.y += gmapFieldLayer.tempArea.position.y;
      dragEndFieldFix();
      // 再度addしても表示されない（謎）ため、インスタンスを作成しなおし
      // gmapFieldLayer.mainArea.add(fieldPiece);
      FieldPiece xxpiece = FieldPiece(fieldPiece.fieldType,
          initX: fieldPiece.position.x,
          initY: fieldPiece.position.y,
          column: fieldPiece.column,
          row: fieldPiece.row);
      gmapFieldLayer.mainArea.add(xxpiece);
      // checkPieceList(xxpiece);
      for (var i = 0; i < gmapFieldLayer.tempPieceList.length; i++) {
        final effect = MoveEffect.to(Vector2(i * 5, i * 5),
            EffectController(duration: 1, curve: Curves.bounceOut));
        gmapFieldLayer.tempPieceList[i].add(effect);
      }
    } else {
      dragEndFieldFix();
      // checkPieceList(fieldPiece);
    }
    FlameAudio.play('place.mp3');
    super.onDragEnd(event);
  }

  draggingField(DragUpdateEvent event) {
    //DragUpdateEventからは、ドラッグでの移動量をevent.deltaで取得できる。
    fieldPiece
      ..position.x += event.delta.x
      ..position.y += event.delta.y;

    if (fieldPiece.position.x < -kFieldWidth / 2 + kHexWidth / 2) {
      fieldPiece.position.x = -kFieldWidth / 2 + kHexWidth / 2;
      FlameAudio.play('glass.mp3');
    }
    if (fieldPiece.position.y < -kFieldHeight / 2 + kHexHeight / 2 + 1) {
      fieldPiece.position.y = -kFieldHeight / 2 + kHexHeight / 2 + 1;
      FlameAudio.play('glass.mp3');
    }
    if (fieldPiece.position.x > kFieldWidth / 2 - kHexWidth / 2) {
      fieldPiece.position.x = kFieldWidth / 2 - kHexWidth / 2 - 1;
      FlameAudio.play('glass.mp3');
    }
    if (fieldPiece.position.y > kFieldHeight / 2 - kHexHeight / 2 - 1) {
      fieldPiece.position.y = kFieldHeight / 2 - kHexHeight / 2 - 1;
      FlameAudio.play('glass.mp3');
    }
  }

  void dragEndFieldFix() {
    //hex駒の列位置(0～nn)。x軸座標を「hex駒の幅の3/4（左右1/4が隣の駒と重なる）」で割って四捨五入。
    var hexColumn = (fieldPiece.position.x / kHexWidth / 0.75).round();
    //hex駒の補正後x軸座標。hex駒の列位置＊hex駒の幅＊3/4。
    var positionX = hexColumn * kHexWidth * 0.75;
    var hexRow = 0;
    var positionY = 0.0;
    if (hexColumn.isOdd) {
      //hex駒の行位置(0～nn)。centerアンカー分(hex駒の高さの1/2)を引いてから、hex駒の高さで割って四捨五入
      hexRow = ((fieldPiece.position.y - kHexHeight / 2) / kHexHeight).round();
      //hex駒の補正後y軸座標。hex駒の行位置＊hex駒の高さ+hex駒の高さの1/2。
      positionY = hexRow * kHexHeight + kHexHeight / 2;
    } else {
      //hex駒の行位置(0～nn)。hex駒の高さで割って四捨五入
      hexRow = (fieldPiece.position.y / kHexHeight).round();
      //hex駒の補正後y軸座標。hex駒の行位置＊hex駒の高さ。
      positionY = hexRow * kHexHeight;
    }

    fieldPiece.position.x = positionX;
    fieldPiece.position.y = positionY;
    fieldPiece.column = hexColumn + kFieldColumnOffset;
    fieldPiece.row = hexRow + kFieldRowOffset;
  }

  void checkPieceList(FieldPiece xxpiece) {
    if (gmapFieldLayer.pieceList[xxpiece.column][xxpiece.row].fieldType ==
        'null') {
      gmapFieldLayer.pieceList[xxpiece.column][xxpiece.row] = xxpiece;
    } else {
      for (int i = 1; i < 4; i++) {
        bool findFreeHex = false;
        for (int xcol = xxpiece.column - i;
            xcol < xxpiece.column + i + 1;
            xcol++) {
          for (int xrow = xxpiece.row - i; xrow < xxpiece.row + i + 1; xrow++) {
            if (!findFreeHex &&
                (xrow == xxpiece.row - i ||
                    xrow == xxpiece.row + i ||
                    xcol == xxpiece.column - i ||
                    xcol == xxpiece.column + i)) {
              if (gmapFieldLayer.pieceList[xcol][xrow].fieldType == 'null') {
                findFreeHex = true;
                gmapFieldLayer.pieceList[xcol][xrow] = xxpiece;
                double positionX = xcol * kHexWidth * 0.75;
                double positionY = 0;
                if (xcol.isOdd) {
                  positionY = xrow * kHexHeight + kHexHeight / 2;
                } else {
                  positionY = xrow * kHexHeight;
                }
                final effect = MoveEffect.to(Vector2(positionX, positionY),
                    EffectController(duration: 1, curve: Curves.bounceInOut));
                xxpiece.add(effect);
              }
            }
          }
        }
      }
    }
  }
}

class FieldButton extends PositionComponent {
  FieldButton(this.fieldType, this.column, this.row)
      : super(
          size: Vector2(0, 0),
          position: Vector2.all(0), //あとでcolumnより計算
          anchor: Anchor.center,
          scale: Vector2(1.0, 1.0),
        ) {
    calculatePosition(column, row); //position計算

    final xxpaint = BasicPalette.red.paint()..style = PaintingStyle.stroke;
    final imagesLoader = Images();
    Future<Image> image =
        imagesLoader.load(kFieldImage[fieldType] ?? 'hex_null.png');
    Future<SpriteComponent> fieldSprite =
        image.then((Image i) => SpriteComponent(
              sprite: Sprite(i),
              size: Vector2(kHexWidth, kHexHeight),
              scale: Vector2(1.0, 1.0),
              position: Vector2.all(0),
              anchor: Anchor.center,
              paint: xxpaint,
            ));
    fieldSprite.then((SpriteComponent fie) => add(fie));

    //HEX geometry
    final List<Vector2> fieldVerticesList = ([
      Vector2(0.0, -1 * kHexHeight / 2),
      Vector2(-1 * kHexWidth / 2, -1 * kHexHeight / 4),
      Vector2(-1 * kHexWidth / 2, kHexHeight / 4),
      Vector2(0.0, kHexHeight / 2),
      Vector2(kHexWidth / 2, kHexHeight / 4),
      Vector2(kHexWidth / 2, -1 * kHexHeight / 4),
    ]);

    const Anchor hexAnchor = Anchor.center;
    final FieldButtonHEX fieldHEX = FieldButtonHEX(
      fieldButton: this,
      fieldVerticesList: fieldVerticesList,
      hexAnchor: hexAnchor,
      xxpaint: xxpaint,
    );
    add(fieldHEX);
  }
  final String fieldType;
  int column;
  int row;

  void calculatePosition(int argColumn, int argRow) {
    position.x = argColumn * kHexWidth * 0.75;
    if (argColumn.isOdd) {
      position.y = argRow * kHexHeight + kHexHeight / 2 + kHexHeight / 2 + 5;
      //margin 10
    } else {
      position.y = argRow * kHexHeight + kHexHeight / 2 + 5; //margin 10
    }
  }

  @override
  Future<void> onLoad() async {
    return super.onLoad();
  }
}

//クリックはTapCallbacksをmixin「onTapUp(TapUpEvent event)」をオーバーライドする。
class FieldButtonHEX extends PolygonComponent
    with DragCallbacks, TapCallbacks, HasGameRef {
  FieldButtonHEX(
      {required this.fieldButton,
      required this.fieldVerticesList,
      required this.hexAnchor,
      required this.xxpaint})
      : super(
          fieldVerticesList,
          position: Vector2.all(0),
          scale: Vector2(1.0, 1.0),
          paint: xxpaint,
          angle: pi / 2,
          anchor: hexAnchor,
        );

  final FieldButton fieldButton;
  final List<Vector2> fieldVerticesList;
  final Anchor hexAnchor;
  final Paint xxpaint;

  @override
  Future<void> onLoad() async {
    return super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) {
    var xxidx = gmapFieldLayer.tempPieceList.length;
    //ここでtempAreaのポジションからcolumn,rowを算出し、
    //pieceList(r,c)がnullかどうかを確認。null以外なら
    //周りのセルから順番に空きを探す。
    //空きがあればそこにfieldpieceを配置する。
    //fieldpieceのenddrugでは、移動後の位置にnull以外が
    //あったら周りの空きせるにeffect移動
    var hexColumn =
        (gmapFieldLayer.tempArea.position.x / kHexWidth / 0.75).round();
    var hexRow = 0;
    if (hexColumn.isOdd) {
      hexRow =
          ((gmapFieldLayer.tempArea.position.y - kHexHeight / 2) / kHexHeight)
              .round();
    } else {
      hexRow = (gmapFieldLayer.tempArea.position.y / kHexHeight).round();
    }
    hexRow += kFieldRowOffset;
    hexColumn += kFieldColumnOffset;

    if (xxidx < 10) {
      FlameAudio.play('draw.mp3');
      FieldPiece xxpiece = FieldPiece(fieldButton.fieldType,
          initX: xxidx * 5, initY: xxidx * 5, tempMode: true);
      xxpiece.priority = 99; //temp時は99。移動時も99。main時は1。
      gmapFieldLayer.tempPieceList.add(xxpiece);
      gmapFieldLayer.tempArea.add(gmapFieldLayer
          .tempPieceList[gmapFieldLayer.tempPieceList.length - 1]);
    } else {
      //仮置きpieceが多すぎで追加不可。beep
      FlameAudio.play('beep.mp3');
    }
    super.onTapUp(event);
  }
}
