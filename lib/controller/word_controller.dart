import '../model/word_model.dart';

class WordController {
  final WordModel model;

  WordController(this.model);

  Future<void> initialize() async {
    await model.loadCSV();
    await model.loadState();
  }

  void checkAnswer(String guessedWord, Function onCorrect, Function onIncorrect) {
    if (guessedWord == model.word) {
      model.correctGuessesInLevel++;
      model.wordsGuessed++;
      model.savePoints();

      if (model.isLevelBasedMode && model.wordsGuessed % 10 == 0) {
        model.currentLevel++;
        model.wordsGuessed = 0;
        model.correctGuessesInLevel = 0;
        model.incrementWordIndex();
        onCorrect(true);  // Level completed
      } else {
        model.incrementWordIndex();
        onCorrect(false);
      }
    } else {
      onIncorrect();
    }
  }


  void saveState() {
    model.saveState();
  }
}
