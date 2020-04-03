import 'package:flutter/material.dart';
import 'dart:collection';

import './sudoku_cell.dart';

class SudokuSolver {
  void calculatePossibilities(SudokuCell cell, List<List<int>> board) {
    rowPossiblities(cell, board);
    colPossiblities(cell, board);
    regionPossiblities(cell, board);
  }

  void rowPossiblities(SudokuCell cell, List<List<int>> board) {
    for (int i = 0; i < board.length; i++) {
      if (board[cell.row][i] != 0)
        cell.setPossibility(false, board[cell.row][i]);
    }
  }

  void colPossiblities(SudokuCell cell, List<List<int>> board) {
    for (int i = 0; i < board.length; i++) {
      if (board[i][cell.col] != 0)
        cell.setPossibility(false, board[i][cell.col]);
    }
  }

  void regionPossiblities(SudokuCell cell, List<List<int>> board) {
    int xRegion = cell.row ~/ 3;
    int yRegion = cell.col ~/ 3;
    for (int x = xRegion * 3; x < xRegion * 3 + 3; x++) {
      for (int y = yRegion * 3; y < yRegion * 3 + 3; y++) {
        if (board[x][y] != 0) cell.setPossibility(false, board[x][y]);
      }
    }
  }

  Map<String, int> getNextEmptyCell(List<List<int>> board) {
    for (int i = 0; i < board.length; i++)
      for (int j = 0; j < board.length; j++)
        if (board[i][j] == 0) return {'row': i, 'col': j};
    return null;
  }

  void printBoard(List<List<int>> board) {
    debugPrint(board.toString());
  }

  List<List<int>> solveSudoku(List<List<int>> board) {
    Queue<SudokuCell> cellStack = Queue<SudokuCell>();
    Map<String, int> nextEmptyCell = this.getNextEmptyCell(board);
    SudokuCell current = SudokuCell(
      row: nextEmptyCell['row'],
      col: nextEmptyCell['col'],
      board: board,
    );
    while (true) {
      this.calculatePossibilities(current, board);
      if (current.getNumberOfChoices() == 0) {
        // Wrong Route!, so reset stuff (backtrack!)
        current = cellStack.removeLast(); // pop!

        // Set the possiblilty for the current number as false - as it is wrong
        current.setPossibility(
          false,
          current.getBoardNumber(current.row, current.col),
        );

        // Reset the board cell
        current.setBoardCell(
          current.row,
          current.col,
          0,
        );

        // Get the updated board
        board = current.getBoard();
      } else {
        // Set the value as first element from possible values
        current.setBoardCell(
          current.row,
          current.col,
          current.getPossibleIntArray()[0],
        );

        // Push the Cell state.
        cellStack.addLast(current); // Push!

        // get the updated board.
        board = current.getBoard();

        // get the the next empty cell for this board.
        nextEmptyCell = this.getNextEmptyCell(board);

        // No cells are empty, break from loop.
        if (nextEmptyCell == null) break;

        // update current to point to the new sudoku cell
        current = new SudokuCell(
          row: nextEmptyCell['row'],
          col: nextEmptyCell['col'],
          board: board,
        );
      }
    }
    return board;
  }
}
