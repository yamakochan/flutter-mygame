import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/block_breaker.dart';
import 'overlays/main_menu.dart';
import 'overlays/field_menu.dart';

void main() {
  //FlameGameを継承したゲームループをインスタンス化する。
  //ビルドメソッド内でゲームをインスタンス化すると、Flutterツリーがリビルドされるたびに
  //ゲームが再構築されコストが高い。ビルドメソッド外でインスタンス化することが重要
  final game = BlockBreaker();
  //runApp()関数は、指定されたWidgetを受け取り、それをウィジェットツリーのルートにします。
  //runApp(GameWidget(game: game)); ／ runApp(GameWidget.controlled(gameFactory: MyGame.new));
  runApp(
    //Material Designアプリケーションのルートウィジェットとして使用（アプリ全体で共通のテーマやナビゲーション、ローカリゼーションなどを設定できる）
    MaterialApp(
      debugShowCheckedModeBanner: false,
      //SafeArea：OS側でスマホの上下に出しているシステムI/F（時計、バッテリーとか）をいい感じに避けてくれるWidget
      home: SafeArea(
        //GameWidgetはゲームクラスのインスタンスを元に、画面にゲームを表示するWidget
        child: GameWidget(
          //FlameGameを継承したゲームループをインスタンス化し、GameWidgetに渡すことでFlutterツリーに追加
          game: game,
          //gameキャンパスの上にWidgetを重ねて表示するため、overlayBuilderMapに２個のWidgetを登録
          //overlaysプロパティはゲームループ内から自由に参照可能。
          //overlays.add('FieldMenu')でFieldMenuをゲーム画面に重ねて表示。overlays.remove('FieldMenu')でWidgetを削除。
          overlayBuilderMap: {
            'MainMenu': (_, pgame) => MainMenu(game: game),
            'FieldMenu': (_, pgame) => FieldMenu(game: game),
          },
          //GameWidgetのinitialActiveOverlaysにゲームが開始した際に前面に来るウィジェットを登録
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    ),
  );
}
