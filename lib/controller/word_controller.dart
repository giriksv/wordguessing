import '../model/word_model.dart';

class WordController {
  final WordModel model;

  WordController(this.model);

  /// Initialize the model by loading the CSV and state
  Future<void> initialize() async {
    await model.loadCSV();
    await model.loadState();
  }

  /// Check if the guessed word is correct and update state accordingly
  void checkAnswer(String guessedWord, Function onCorrect, Function onIncorrect) {
    if (guessedWord == model.word) {
      model.correctGuessesInLevel++;
      model.wordsGuessed++;
      model.savePoints();

      if (model.isLevelBasedMode && model.wordsGuessed % 10 == 0) {
        // Completed level
        model.currentLevel++;
        model.wordsGuessed = 0;
        model.correctGuessesInLevel = 0;
        model.incrementWordIndex();
        model.saveState();
        onCorrect(true);  // Level completed
      } else {
        model.incrementWordIndex();
        model.saveState();
        onCorrect(false);
      }
    } else {
      onIncorrect();
    }
  }

  /// Save the current state
  void saveState() {
    model.saveState();
  }
}
