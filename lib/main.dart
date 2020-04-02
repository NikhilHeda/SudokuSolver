import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_parts/sudoku_solver.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Sudoku!"),
        ),
        body: SudokuSolverPage(),
      ),
    );
  }
}

class SudokuSolverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SudokuChangeNotifier>(
      create: (context) => SudokuChangeNotifier(),
      child: Column(
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
            child: Consumer<SudokuChangeNotifier>(
                builder: (context, sudokuChangeNotifier, child) {
              return Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        child: Text('Solve!'),
                        onPressed: () {
                          debugPrint('Solving Board');
                          sudokuChangeNotifier.solveBoard();
                        },
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
                          sudokuChangeNotifier.resetBoard();
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class SudokuBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Table(
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
      return SudokuCell(rowNumber, colNumber);
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
        Provider.of<SudokuChangeNotifier>(context, listen: false)
            .setBoardCell(this.row, this.col);
      },
      child: SizedBox(
        width: 30,
        height: 30,
        child: Container(
          child: Center(
            child: Consumer<SudokuChangeNotifier>(
                builder: (context, sudokuChangeNotifier, child) {
              return Text(
                // Using board cell value.
                sudokuChangeNotifier.getBoardCell(this.row, this.col),
              );
            }),
          ),
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
      child: FlatButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () {
          final String message = number == 0
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
  final solver = SudokuSolver();

  String getBoardCell(int row, int col) {
    return this.board[row][col] == 0 ? '' : this.board[row][col].toString();
  }

  void setBoardCell(int row, int col) {
    this.board[row][col] = this.activeNumber;
    notifyListeners();
  }

  void setActiveNumber(int number) {
    this.activeNumber = number;
  }

  void solveBoard() {
    solver.solveSudoku(this.board);
    notifyListeners();
  }

  void resetBoard() {
    this.board = List.generate(9, (_) => List.generate(9, (_) => 0));
    this.activeNumber = 0;
    notifyListeners();
  }
}
