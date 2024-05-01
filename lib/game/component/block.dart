import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../constants/constants.dart';
import 'ball.dart';

class Blockxx extends RectangleComponent with CollisionCallbacks {
  Blockxx({required this.blockSize})
      : super(
          size: blockSize,
          paint: Paint()
            ..color = kBlockColors[Random().nextInt(kBlockColors.length)],
        );

  final Vector2 blockSize;

  @override
  Future<void>? onLoad() async {
    final blockHitbox = RectangleHitbox(
      size: size,
    );

    await add(blockHitbox);

    return super.onLoad();
  }

  @override
  void onCollisionStart(
    //衝突している物体同士の交点がintersectionPoints、衝突相手がotherで取得できる。
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Ball) {
      removeFromParent();
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
