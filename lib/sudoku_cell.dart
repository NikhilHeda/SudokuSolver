class SudokuCell {
  int row = -1;
  int col = -1;

  List<List<int>> board;
  List<bool> possibilities;

  SudokuCell({this.row, this.col, this.board}) {
    this.possibilities = List<bool>.filled(9, true);
  }

  // Getters
  int getNumberOfChoices() {
    int _count = 0;
    this.possibilities.forEach((value) {
      if (value) _count++;
    });
    return _count;
  }

  List<int> getPossibleIntArray() {
    var _availableChoices = this.getNumberOfChoices();
    if (_availableChoices == 0) {
      return null;
    } else {
      List<int> possibleInt = List<int>(_availableChoices);
			for (int i = 0, j = 0; i < this.possibilities.length; i++) {
				if (this.possibilities[i]) {
					possibleInt[j] = i + 1;
					j++;
				}
			}
			return possibleInt;
    }
  }

  int getBoardNumber(int row, int col) {
    return this.board[row][col];
  }

  List<List<int>> getBoard() {
    return this.board;
  }

  // Setters
  void setPossibility(bool state, int number) {
    this.possibilities[number - 1] = state;
  }

  void setBoardCell(int row, int col, int value) {
    this.board[row][col] = value;
  }
}
