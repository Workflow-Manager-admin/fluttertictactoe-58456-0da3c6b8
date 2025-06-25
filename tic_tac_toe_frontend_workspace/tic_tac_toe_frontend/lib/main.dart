import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

/// TicTacToeApp is the root widget for the application
// PUBLIC_INTERFACE
class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1976D2),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF1976D2),
        secondary: const Color(0xFF43A047),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        surface: Colors.white,
        background: Colors.white,
        error: Colors.red[700]!,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFFC107),
        foregroundColor: Colors.black,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
        displayMedium: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black87),
        headlineSmall: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
      ),
      scaffoldBackgroundColor: Colors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      home: const TicTacToeHomePage(),
    );
  }
}

/// Main page for Tic Tac Toe game, stateful for current game/session management
// PUBLIC_INTERFACE
class TicTacToeHomePage extends StatefulWidget {
  const TicTacToeHomePage({super.key});

  @override
  State<TicTacToeHomePage> createState() => _TicTacToeHomePageState();
}

enum Player { X, O }
enum GameStatus { active, draw, won }

class _TicTacToeHomePageState extends State<TicTacToeHomePage>
    with SingleTickerProviderStateMixin {
  static const int boardSize = 3;

  late List<List<Player?>> board;
  Player currentPlayer = Player.X;
  GameStatus status = GameStatus.active;
  Player? winner;

  // Local score for both players
  int xScore = 0;
  int oScore = 0;
  int drawScore = 0;

  late AnimationController _controller;
  late Animation<double> _boardAnimation;

  @override
  void initState() {
    super.initState();
    _resetBoard(fullReset: true);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _boardAnimation = CurvedAnimation(
        parent: _controller, curve: Curves.easeInOutCubicEmphasized);
    _controller.forward();
  }

  // Resets the game board. If fullReset, scores are left unchanged.
  // PUBLIC_INTERFACE
  void _resetBoard({bool fullReset = false}) {
    setState(() {
      board = List.generate(
          boardSize, (_) => List<Player?>.filled(boardSize, null));
      status = GameStatus.active;
      winner = null;
      currentPlayer = Player.X;
      if (fullReset) {
        xScore = 0;
        oScore = 0;
        drawScore = 0;
      }
      _controller.reset();
      _controller.forward();
    });
  }

  // Handles a user move at position (row, col)
  // PUBLIC_INTERFACE
  void _onCellTap(int row, int col) {
    if (board[row][col] != null || status != GameStatus.active) return;
    setState(() {
      board[row][col] = currentPlayer;
      if (_checkWinner(row, col, currentPlayer)) {
        status = GameStatus.won;
        winner = currentPlayer;
        if (winner == Player.X) {
          xScore++;
        } else {
          oScore++;
        }
      } else if (_isBoardFull()) {
        status = GameStatus.draw;
        drawScore++;
      } else {
        currentPlayer = currentPlayer == Player.X ? Player.O : Player.X;
      }
      _controller.reset();
      _controller.forward();
    });
  }

  // Checks if the board is full (for draw detection)
  bool _isBoardFull() {
    for (var row in board) {
      for (var cell in row) {
        if (cell == null) return false;
      }
    }
    return true;
  }

  // Checks if the last move caused a win for the specified player
  bool _checkWinner(int lastRow, int lastCol, Player player) {
    // Check row
    bool winRow = true, winCol = true, winDiag = true, winAntiDiag = true;
    for (var i = 0; i < boardSize; i++) {
      if (board[lastRow][i] != player) winRow = false;
      if (board[i][lastCol] != player) winCol = false;
      if (board[i][i] != player) winDiag = false;
      if (board[i][boardSize - i - 1] != player) winAntiDiag = false;
    }
    return winRow || winCol || winDiag || winAntiDiag;
  }

  Widget _buildScoreDisplay() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ScoreBox(
            label: 'Player X',
            score: xScore,
            color: Theme.of(context).colorScheme.primary,
            isCurrent: currentPlayer == Player.X && status == GameStatus.active,
          ),
          _ScoreBox(
            label: 'Draws',
            score: drawScore,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            isCurrent: false,
          ),
          _ScoreBox(
            label: 'Player O',
            score: oScore,
            color: Theme.of(context).colorScheme.secondary,
            isCurrent: currentPlayer == Player.O && status == GameStatus.active,
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatusText() {
    String text;
    Color? color;
    switch (status) {
      case GameStatus.active:
        text = 'Turn: ${currentPlayer == Player.X ? "X" : "O"}';
        color = currentPlayer == Player.X
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary;
        break;
      case GameStatus.draw:
        text = "It's a draw!";
        color = Colors.grey[700];
        break;
      case GameStatus.won:
        text = 'Winner: ${winner == Player.X ? "X" : "O"} 🎉';
        color = winner == Player.X
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary;
        break;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Text(
          text,
          key: ValueKey<String>(text),
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(color: color, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    double boardWidth = MediaQuery.of(context).size.width * 0.9;
    if (MediaQuery.of(context).size.height < 600) {
      boardWidth = MediaQuery.of(context).size.width * 0.85;
    }
    final double cellSize = boardWidth / boardSize;
    return ScaleTransition(
      scale: _boardAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            boardSize,
            (row) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                boardSize,
                (col) => _AnimatedCell(
                  key: ValueKey('${row}_$col_${board[row][col]}'),
                  symbol: board[row][col],
                  onTap: () => _onCellTap(row, col),
                  size: cellSize,
                  highlight: board[row][col] != null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              textStyle: const TextStyle(fontSize: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _resetBoard(fullReset: false),
            label: const Text('Restart'),
          ),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.clear_all_rounded),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: const TextStyle(fontSize: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _resetBoard(fullReset: true),
            label: const Text('Clear Scores'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive constraints
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: isPortrait
                  ? const EdgeInsets.symmetric(horizontal: 0)
                  : const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildScoreDisplay(),
                  _buildGameStatusText(),
                  const SizedBox(height: 10),
                  _buildGameBoard(),
                  _buildControls(),
                  const SizedBox(height: 12),
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      'Player X: ${"X"}   Player O: ${"O"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Widget for the individual cell, with minimal animation.
/// Renders X or O depending on the player.
class _AnimatedCell extends StatefulWidget {
  final Player? symbol;
  final VoidCallback onTap;
  final double size;
  final bool highlight;

  const _AnimatedCell({
    required Key key,
    required this.symbol,
    required this.onTap,
    required this.size,
    required this.highlight,
  }) : super(key: key);

  @override
  State<_AnimatedCell> createState() => _AnimatedCellState();
}

class _AnimatedCellState extends State<_AnimatedCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _cellController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _cellController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnimation =
        CurvedAnimation(parent: _cellController, curve: Curves.easeOutBack);
    if (widget.symbol != null) {
      _cellController.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.symbol != null && oldWidget.symbol == null) {
      _cellController.forward(from: 0);
    }
    if (widget.symbol == null) {
      _cellController.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double border = widget.size * 0.03;
    return GestureDetector(
      onTap: widget.symbol == null ? widget.onTap : null,
      child: Container(
        margin: EdgeInsets.all(widget.size * 0.025),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.size * 0.18),
          border: Border.all(
            color: widget.highlight
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.16)
                : Colors.grey[300]!,
            width: border,
          ),
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: widget.symbol == null
                ? null
                : widget.symbol == Player.X
                    ? _DrawX(size: widget.size * 0.5)
                    : _DrawO(size: widget.size * 0.5),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cellController.dispose();
    super.dispose();
  }
}

/// ScoreBox displays player or draw scores.
class _ScoreBox extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final bool isCurrent;

  const _ScoreBox({
    required this.label,
    required this.score,
    required this.color,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrent ? color.withOpacity(0.18) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(isCurrent ? 0.32 : 0.19),
          width: isCurrent ? 2 : 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: color, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500),
          ),
          Text(
            '$score',
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: color, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Custom painter widget for 'X'
class _DrawX extends StatelessWidget {
  final double size;
  const _DrawX({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _XPainter(color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _XPainter extends CustomPainter {
  final Color color;
  _XPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.21
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_XPainter oldDelegate) => false;
}

/// Custom painter widget for 'O'
class _DrawO extends StatelessWidget {
  final double size;
  const _DrawO({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _OPainter(color: Theme.of(context).colorScheme.secondary),
    );
  }
}

class _OPainter extends CustomPainter {
  final Color color;
  _OPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.19
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - paint.strokeWidth / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(_OPainter oldDelegate) => false;
}
