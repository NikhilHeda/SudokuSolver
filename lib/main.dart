import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/sudoku_solver.dart';
import 'package:tuple/tuple.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Solver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Sudoku!"),
        ),
        body: ChangeNotifierProvider<SudokuChangeNotifier>(
          create: (context) => SudokuChangeNotifier(),
          child: SudokuSolverPage(),
        ),
      ),
    );
  }
}

class SudokuSolverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SudokuBoard(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: KeyPad(),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer<SudokuChangeNotifier>(
                    builder: (context, sudokuChangeNotifer, child) {
                      return RaisedButton(
                        child: child,
                        onPressed: sudokuChangeNotifer.isValid
                            ? () {
                                debugPrint('Solving Board');
                                sudokuChangeNotifer.solveBoard();
                              }
                            : null,
                      );
                    },
                    child: Text('Solve!'),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text('Reset Board'),
                    onPressed: () {
                      debugPrint('Resetting Board');
                      Provider.of<SudokuChangeNotifier>(context, listen: false)
                          .reset();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SudokuBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(
        left: BorderSide(width: 3.0, color: Colors.black),
        top: BorderSide(width: 3.0, color: Colors.black),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: _getTableRows(),
    );
  }

  List<TableRow> _getTableRows() {
    return List.generate(9, (int rowNumber) {
      return TableRow(children: _getRow(rowNumber));
    });
  }

  List<Widget> _getRow(int rowNumber) {
    return List.generate(9, (int colNumber) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              width: (colNumber % 3 == 2) ? 3.0 : 1.0,
              color: Colors.black,
            ),
            bottom: BorderSide(
              width: (rowNumber % 3 == 2) ? 3.0 : 1.0,
              color: Colors.black,
            ),
          ),
        ),
        child: SudokuCell(rowNumber, colNumber),
      );
    });
  }
}

class SudokuCell extends StatelessWidget {
  final int row, col;

  SudokuCell(this.row, this.col);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      enableFeedback: true,
      onTap: () {
        // Set the board cell to activeNumber...
        Provider.of<SudokuChangeNotifier>(context, listen: false)
            .setBoardCell(this.row, this.col);
      },
      child: SizedBox(
        width: 30,
        height: 30,
        child: Selector<SudokuChangeNotifier, Tuple2<String, Color>>(
          builder: (context, data, child) {
            // Using selector to rebuild, only if the value changes
            // Using board cell value.
            return Container(
              color: data.item2,
              child: Center(
                child: Text(data.item1),
              ),
            );
          },
          selector: (context, sudokuChangeNotifier) => Tuple2(
              sudokuChangeNotifier.getBoardCell(this.row, this.col),
              sudokuChangeNotifier.getBoardCellColor(this.row, this.col)),
        ),
      ),
    );
  }
}

class KeyPad extends StatelessWidget {
  final int numRows = 2;
  final int numColumns = 5;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: Colors.black,
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: _getTableRows(),
    );
  }

  List<TableRow> _getTableRows() {
    return List.generate(this.numRows, (int rowNumber) {
      return TableRow(children: _getRow(rowNumber));
    });
  }

  List<Widget> _getRow(int rowNumber) {
    return List.generate(this.numColumns, (int colNumber) {
      return Padding(
        padding: const EdgeInsets.all(5),
        child: KeyPadCell(this.numColumns * rowNumber + colNumber),
      );
    });
  }
}

class KeyPadCell extends StatelessWidget {
  final int number;

  KeyPadCell(this.number);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 50,
      child: Selector<SudokuChangeNotifier, Color>(
        builder: (context, buttonColor, child) {
          return FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            color: buttonColor,
            onPressed: () {
              final String message = this.number == 0
                  ? 'Use to clear squares'
                  : 'Fill all squares with value $number';
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(message),
                duration: Duration(seconds: 1),
              ));

              // Setting activeNumber here...
              Provider.of<SudokuChangeNotifier>(context, listen: false)
                  .setActiveNumber(this.number);
            },
            child: child,
          );
        },
        selector: (context, sudokuChangeNotifier) =>
            sudokuChangeNotifier.getKeyPadColor(this.number),
        child: Text(
          '$number',
        ),
      ),
    );
  }
}

class SudokuChangeNotifier with ChangeNotifier {
  List<List<int>> board = List.generate(9, (_) => List.generate(9, (_) => 0));
  int activeNumber = 0;

  List<List<Color>> sudokuCellColors =
      List.generate(9, (_) => List.generate(9, (_) => Colors.white));

  List<Color> keyPadColors = List.generate(10, (_) => Colors.white);

  bool isValid = true;

  final solver = SudokuSolver();

  String getBoardCell(int row, int col) {
    return this.board[row][col] == 0 ? '' : this.board[row][col].toString();
  }

  void setBoardCell(int row, int col) {
    this.board[row][col] = this.activeNumber;

    this.sudokuCellColors[row][col] =
        this.activeNumber == 0 ? Colors.white : Colors.yellow;

    // this.isValid = isValidOnChange(row, col, this.activeNumber);
    this.isValid = this.isBoardValid();

    // Notifying listeners, as board[row][col] changed
    // so need to rebuild SudokuCell using board[row][col].
    notifyListeners();
  }

  Color getBoardCellColor(int row, int col) {
    return this.sudokuCellColors[row][col];
  }

  Color getKeyPadColor(int number) {
    return this.keyPadColors[number];
  }

  void setKeyPadColor(int number, Color color) {
    this.keyPadColors[number] = color;
    notifyListeners();
  }

  int getActiveNumber(int number) {
    return this.activeNumber;
  }

  void setActiveNumber(int number) {
    // Reset the previous active number color
    this.keyPadColors[this.activeNumber] = Colors.white;

    // Set the active number and color
    this.activeNumber = number;
    this.keyPadColors[this.activeNumber] = Colors.yellow;

    notifyListeners();
  }

  void solveBoard() {
    solver.solveSudoku(this.board);
    // Notifying listeners, as board changed
    // so need to rebuild all widgets using board.
    notifyListeners();
  }

  void reset() {
    this.resetBoard();
    this.resetSudokuCellColors();
    this.resetKeyPadColors();

    // Notifying listeners, as board changed
    // so need to rebuild all widgets using board.
    notifyListeners();
  }

  void resetBoard() {
    this.board = List.generate(9, (_) => List.generate(9, (_) => 0));
    this.activeNumber = 0;
  }

  void resetSudokuCellColors() {
    this.sudokuCellColors =
        List.generate(9, (_) => List.generate(9, (_) => Colors.white));
  }

  void resetKeyPadColors() {
    this.keyPadColors = List.generate(10, (_) => Colors.white);
  }

  bool isValidOnChange(int row, int col, int number) {
    if (number == 0) return true;

    // Checking row
    for (int currCol = 0; currCol != col && currCol < 9; ++currCol) {
      if (this.board[row][currCol] == number) {
        debugPrint('Column is invalid $currCol');
        return false;
      }
    }

    // Checking col
    for (int currRow = 0; currRow != row && currRow < 9; ++currRow) {
      if (this.board[currRow][col] == number) {
        debugPrint('Row is invalid $currRow');
        return false;
      }
    }

    // Checking region
    int xRegion = row ~/ 3;
    int yRegion = col ~/ 3;
    for (int x = xRegion * 3; x < xRegion * 3 + 3; x++) {
      for (int y = yRegion * 3; y < yRegion * 3 + 3; y++) {
        if (!(x == row && y == col) && this.board[x][y] == number) {
          debugPrint('Row, col is invalid ($x,$y)');
          return false;
        }
      }
    }

    return true;
  }

  bool isBoardValid() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (!(isRowValid(row) && isColumnValid(col) && isRegionValid(row, col)))
          return false;
      }
    }
    return true;
  }

  bool isRowValid(int row) {
    return this.areDuplicatesPresent(this.board[row].toList(growable: false));
  }

  bool isColumnValid(int col) {
    return this.areDuplicatesPresent(
        this.board.map((rowElem) => rowElem[col]).toList(growable: false));
  }

  bool isRegionValid(int row, int col) {
    List<int> region = List<int>();
    int xRegion = row ~/ 3;
    int yRegion = col ~/ 3;
    for (int x = xRegion * 3; x < xRegion * 3 + 3; x++) {
      for (int y = yRegion * 3; y < yRegion * 3 + 3; y++) {
        region.add(this.board[x][y]);
      }
    }

    return this.areDuplicatesPresent(region);
  }

  bool areDuplicatesPresent(List<int> a) {
    a.sort();
    for (int i = 1; i < a.length; i++)
      if (a[i] != 0 && a[i - 1] == a[i]) return false;
    return true;
  }
}
