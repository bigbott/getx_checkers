import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import 'package:getx_checkers/app/data/audio/audio_service_interface.dart';
import 'package:getx_checkers/app/modules/common/dialog_manager.dart';

class GameController extends GetxController {
  final AudioServiceInterface _audioService;
  final DialogManager _dialogManager;
  bool blackAutoPlay = true;

  GameController({

    required AudioServiceInterface audioService,
    required DialogManager dialogManager,
  }) : _audioService = audioService, 
       _dialogManager = dialogManager ;

  int? selectedPieceIndex;
  List<int> validMoves = [];
  List<Map<String, dynamic>?> squares = List.filled(64, null);
  bool isWhiteTurn = true;
  bool canChangeSelectedPiece = true;
  late ConfettiController confettiController;

  @override
  void onInit() {
    super.onInit();
    initPieces();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void onClose() {
    confettiController.dispose();
    super.onClose();
  }

  void newGame() {
    squares = List.filled(64, null); // Reset the squares array
    initPieces();
    update();
  }

  void initPieces() {
    for (int i = 0; i < 24; i++) {
      if ((i ~/ 8) % 2 != i % 2) {
        squares[i] = {"isWhite": false, "isKing": false}; // Blacks
      }
    }
    for (int i = 40; i < 64; i++) {
      if ((i ~/ 8) % 2 != i % 2) {
        squares[i] = {"isWhite": true, "isKing": false}; // Whites
      }
    }
  }

  void selectPiece(int index) {
    if (canChangeSelectedPiece && squares[index]!['isWhite'] == isWhiteTurn) {
      // Only allow selecting current player's pieces
      if (squares[index] != null) {
        selectedPieceIndex = index;
        validMoves = calculateValidMoves(
            index, squares[index]!['isWhite'], squares[index]!['isKing']);
        update();
      }
    }
  }

  void movePiece(int index) {
    if (validMoves.contains(index)) {
      squares[index] = squares[selectedPieceIndex!]; // Move piece to new square
      squares[selectedPieceIndex!] = null; // Clear the old square

      // Promote to king if reaching the opposite end
      if ((index < 8 && squares[index]!['isWhite']) ||
          (index >= 56 && !squares[index]!['isWhite'])) {
        squares[index]!['isKing'] = true;
      }

      // Check for captures
      int capturedIndex = (index + selectedPieceIndex!) ~/ 2;
      bool isCaptured = (index - selectedPieceIndex!).abs() > 9;
      if (isCaptured) {
        squares[capturedIndex] = null; // Remove captured piece
        _audioService.playCaptureSound();
        // Check for another capture move after jumping
        List<int> furtherMoves = calculateValidMoves(
            index, squares[index]!['isWhite'], squares[index]!['isKing']);
        if (furtherMoves.isNotEmpty &&
            furtherMoves.any((move) => (move - index).abs() > 9)) {
          // Keep the turn with the current player if more captures are available
          selectedPieceIndex = index;
          validMoves = furtherMoves;
          canChangeSelectedPiece = false;
          return;
        }
      } else {
        _audioService.playMoveSound();
      }
      selectedPieceIndex = null; // Deselect the piece
      validMoves = [];
      isWhiteTurn = !isWhiteTurn; // Switch turns
      canChangeSelectedPiece = true;

      if (checkForVictory()) {
        update();
        return;
      }

      if (!isWhiteTurn && blackAutoPlay) {
        Future.delayed(Duration(milliseconds: 1000), () => makeAutoMove());
      }
      checkForVictory();
    }
    update();
  }

  // Placeholder function for calculating valid moves
  List<int> calculateValidMoves(int index, bool isWhite, bool isKing) {
    List<int> moves = [];
    int row = index ~/ 8;
    int col = index % 8;

    // Add simple move validation (for now, just check diagonal movement)
    if (isKing || !isWhite) {
      if (row < 7 && col > 0 && squares[index + 7] == null) {
        moves.add(index + 7); // Down-left movement
      }
      if (row < 6 &&
          col > 1 &&
          squares[index + 7]?['isWhite'] == !isWhite &&
          squares[index + 14] == null) {
        moves.add(index + 14); // Down-left capture
      }
      if (row > 1 &&
          col > 1 &&
          squares[index - 9]?['isWhite'] == !isWhite &&
          isKing &&
          squares[index - 18] == null) {
        moves.add(index - 18); // Up-left capture (KING)
      }

      if (row < 7 && col < 7 && squares[index + 9] == null) {
        moves.add(index + 9); // Down-right movement
      }
      if (row < 6 &&
          col < 6 &&
          squares[index + 9]?['isWhite'] == !isWhite &&
          squares[index + 18] == null) {
        moves.add(index + 18); // Down-right capture
      }
      if (row > 1 &&
          col < 6 &&
          squares[index - 7]?['isWhite'] == !isWhite &&
          isKing &&
          squares[index - 14] == null) {
        moves.add(index - 14); // Up-right capture (KING)
      }
    }
    if (isKing || isWhite) {
      if (row > 0 && col > 0 && squares[index - 9] == null) {
        moves.add(index - 9); // Up-left movement
      }
      if (row > 1 &&
          col > 1 &&
          squares[index - 9]?['isWhite'] == !isWhite &&
          squares[index - 18] == null) moves.add(index - 18); // Up-left capture
      if (row < 6 &&
          col > 1 &&
          squares[index + 7]?['isWhite'] == !isWhite &&
          isKing &&
          squares[index + 14] == null) {
        moves.add(index + 14); // Down-left capture (KING)
      }

      if (row > 0 && col < 7 && squares[index - 7] == null) {
        moves.add(index - 7); // Up-right movement
      }
      if (row > 1 &&
          col < 6 &&
          squares[index - 7]?['isWhite'] == !isWhite &&
          squares[index - 14] == null)
        moves.add(index - 14); // Up-right capture
      if (row < 6 &&
          col < 6 &&
          squares[index + 9]?['isWhite'] == !isWhite &&
          isKing &&
          squares[index + 18] == null) {
        moves.add(index + 18); // Down-right capture (KING)
      }
    }

    return moves;
  }

  bool checkForVictory() {
    print('checkForVictory was called');
    bool whiteHasPieces = squares.any((piece) => piece?['isWhite'] == true);
    bool blackHasPieces = squares.any((piece) => piece?['isWhite'] == false);

    if (blackHasPieces && whiteHasPieces) {
      return false;
    }

    if (whiteHasPieces) {
      _audioService.playWinSound();
      _dialogManager.showDialog("Victory!", "You won this game!");
      confettiController.play();
    }

    if (blackHasPieces) {
      _audioService.playDefeatSound();
      _dialogManager.showDialog("Defeat.", "You lost. Try again.");
      print("You lost. Try again.");
    }
    return true;
  }

  void makeAutoMove() {
    if (isWhiteTurn) return;

    List<Map<String, dynamic>> allMoves = [];

    while (true) {
      // First check for capture moves
      for (int i = 0; i < squares.length; i++) {
        if (squares[i] != null && !squares[i]!['isWhite']) {
          List<int> moves =
              calculateValidMoves(i, false, squares[i]!['isKing']);
          for (int move in moves) {
            if ((move - i).abs() > 9) {
              // This is a capture move
              allMoves.add({
                'fromIndex': i,
                'toIndex': move,
                'isCapture': true,
              });
            }
          }
        }
      }
      if (allMoves.isNotEmpty) {
        final move =
            allMoves[DateTime.now().millisecondsSinceEpoch % allMoves.length];
        selectPiece(move['fromIndex']);
        movePiece(move['toIndex']);
        allMoves = [];
      } else {
        break;
      }
    }

    // If no capture moves, look for regular moves
    if (allMoves.isEmpty) {
      for (int i = 0; i < squares.length; i++) {
        if (squares[i] != null && !squares[i]!['isWhite']) {
          List<int> moves =
              calculateValidMoves(i, false, squares[i]!['isKing']);
          for (int move in moves) {
            if ((move - i).abs() <= 9) {
              // This is a regular move
              allMoves.add({
                'fromIndex': i,
                'toIndex': move,
                'isCapture': false,
              });
            }
          }
        }
      }
    }

    // Make a random move if available
    if (allMoves.isNotEmpty) {
      final move =
          allMoves[DateTime.now().millisecondsSinceEpoch % allMoves.length];
      selectPiece(move['fromIndex']);
      movePiece(move['toIndex']);
    }
  }

  
}
