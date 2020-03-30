import 'package:flutter/material.dart';
import 'package:sudoku_parts/sudoku_solver.dart';

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
        body: SudokuSolverPage(),
      ),
    );
  }
}

class SudokuSolverPage extends StatefulWidget {
  @override
  _SudokuSolverPageState createState() => _SudokuSolverPageState();
}

class _SudokuSolverPageState extends State<SudokuSolverPage> {
  List<int> _activeNumber = [0];

  List<List<int>> _board = List.generate(9, (_) => List.generate(9, (_) => 0));

  final solver = SudokuSolver();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SudokuBoard(_board, _activeNumber),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: KeyPad(_activeNumber),
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
                  child: RaisedButton(
                    child: Text('Solve!'),
                    onPressed: () {
                      debugPrint('Solving Board');
                      setState(() {
                        solver.solveSudoku(this._board);
                      });
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
                      setState(() {
                        _resetBoard();
                      });
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

  void _resetBoard() {
    this._board = List.generate(9, (_) => List.generate(9, (_) => 0));
    this._activeNumber = [0];
  }
}

class SudokuBoard extends StatelessWidget {
  final List<List<int>> board;
  final List<int> activeNumber;

  SudokuBoard(this.board, this.activeNumber);

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
        child: SudokuCell(rowNumber, colNumber, this.board, this.activeNumber),
      );
    });
  }
}

class SudokuCell extends StatefulWidget {
  final int row, col;
  final List<List<int>> board;
  final List<int> activeNumber;

  SudokuCell(this.row, this.col, this.board, this.activeNumber);

  @override
  _SudokuCellState createState() => _SudokuCellState();
}

class _SudokuCellState extends State<SudokuCell> {
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      enableFeedback: true,
      onTap: () {
        setState(() {
          this.widget.board[this.widget.row][this.widget.col] =
              this.widget.activeNumber[0];
        });
      },
      child: SizedBox(
        width: 30,
        height: 30,
        child: Container(
          child: Center(
            child: Text(this.widget.board[this.widget.row][this.widget.col] == 0
                ? ''
                : this
                    .widget
                    .board[this.widget.row][this.widget.col]
                    .toString()),
          ),
        ),
      ),
    );
  }
}

class KeyPad extends StatelessWidget {
  final int numRows = 2;
  final int numColumns = 5;
  final List<int> activeNumber;

  KeyPad(this.activeNumber);

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
        child: KeyPadCell(
            this.numColumns * rowNumber + colNumber, this.activeNumber),
      );
    });
  }
}

class KeyPadCell extends StatelessWidget {
  final int number;
  final List<int> activeNumber;

  KeyPadCell(this.number, this.activeNumber);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 50,
      child: FlatButton(
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
          this.activeNumber[0] = this.number;
        },
        child: Text(
          '$number',
        ),
      ),
    );
  }
}
