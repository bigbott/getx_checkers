import 'package:button_animations/button_animations.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plus/flutter_plus.dart';
import 'dart:math';

import 'package:get/get.dart';
import 'package:getx_checkers/app/modules/game/widgets/piece.dart';

import 'game_controller.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConfettiWidget(
              confettiController: controller.confettiController,
              blastDirectionality: BlastDirectionality.explosive, 
              blastDirection: pi/2, 
            particleDrag: 0.05, // apply drag to the confetti
            emissionFrequency: 0.05, // how often it should emit
            numberOfParticles: 120, // number of particles to emit
            gravity: 0.05,
            ),
          GetBuilder<GameController>(builder: (controller) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.brown.shade800,
                    width: 5,
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Card(
                    elevation: 3,
                    margin: EdgeInsets.zero,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 64,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                      ),
                      itemBuilder: (context, index) {
                        final isDark = (index ~/ 8) % 2 == 0
                            ? index % 2 == 1
                            : index % 2 == 0;
                        final piece = controller.squares[index];

                        bool isSelected =
                            index == controller.selectedPieceIndex;
                        bool isValidMove =
                            controller.validMoves.contains(index);

                        return GestureDetector(
                            onTap: () {
                              if (piece != null) {
                                controller.selectPiece(index);
                              } else if (isValidMove) {
                                controller.movePiece(index);
                              }
                            },
                            child: Container(
                                color: isDark ? Colors.brown : Colors.white,
                                child: Stack(
                                  children: [
                                    if (isSelected)
                                      Container(
                                          color:
                                              Colors.yellow.withOpacity(0.4)),
                                    if (isValidMove)
                                      Container(
                                          color: Colors.green.withOpacity(0.4)),
                                    if (piece != null)
                                      Center(
                                          child: Piece(
                                              isWhite: piece['isWhite'],
                                              isKing: piece['isKing']))
                                  ],
                                )));
                      },
                    ),
                  ),
                ),
              ),
            );
          }),
          Container(
            width: 400,
            padding: EdgeInsets.all(20),
            child: AnimatedButton(
              width: 300,
              height: 60,
              onTap: () {
                controller.newGame();
              },
              isMultiColor: true,
              isOutline: true,
              colors: [
                Colors.black87,
                Colors.brown,
              ],
              child: TextPlus("New Game", fontSize: 24, color: Colors.white,),
            ),
          ),
        ],
      )),
    );
  }
}
