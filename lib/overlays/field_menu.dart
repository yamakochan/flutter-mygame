import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/block_breaker.dart';
import '../game/component/map_field.dart';

class FieldMenu extends StatelessWidget {
  // Reference to parent game.
  final BlockBreaker game;

  const FieldMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: const Color.fromARGB(0, 0, 0, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          margin: const EdgeInsets.all(5.0),
          height: 250,
          width: 100,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.amberAccent,
                  Colors.deepOrange,
                ],
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 20,
                    offset: Offset(4, 4))
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  game.overlays.remove('FieldMenu');
                  game.fieldList.add(FieldPiece('plain'));
                  game.fieldList.last
                    ..position.x = game.getSizex() / 2
                    ..position.y = game.getSizey() / 2;
                },
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: whiteTextColor,
                // ),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/HEX_forest.png'),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
