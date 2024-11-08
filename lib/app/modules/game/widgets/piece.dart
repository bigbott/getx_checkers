import 'package:flutter/material.dart';

class Piece extends StatelessWidget {
  final bool isWhite;  // Determines if the piece belongs to player 1 or 2
  final bool  isKing;
  
  Piece({super.key, required this.isWhite, required this.isKing });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isWhite ? Colors.white60 : Colors.black,  // Red for player 1, black for player 2
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 3)
          )
        ],
        border: Border.all(color: Colors.white, width: 2)
      ),
      child: isKing ? Center(child: Icon(Icons.star, color: Colors.white, size: 24)) : null,
    );
  }
}