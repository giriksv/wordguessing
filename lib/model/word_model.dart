import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordModel {
  List<List<String>> wordList = [];
  int currentWordIndex = 0;
  int currentLevel = 1;
  int wordsGuessed = 0;
  int correctGuessesInLevel = 0;
  String hint = '';
  String word = '';
  String mode;
  bool isLevelBasedMode;

  WordModel({required this.mode}) : isLevelBasedMode = ['easy', 'medium', 'hard'].contains(mode);

  /// Load words from CSV file
  Future<void> loadCSV() async {
    try {
      final data = await rootBundle.loadString('assets/words.csv');
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);

      wordList = csvTable.where((row) {
        switch (mode) {
          case 'easy':
            return row[2] == 1;
          case 'medium':
            return row[3] == 1;
          case 'hard':
            return row[4] == 1;
          case 'five':
            return row[5] == 1;
          case 'six':
            return row[6] == 1;
          case 'seven':
            return row[7] == 1;
          case 'Free Play':
            return true;
          default:
            return false;
        }
      }).map((row) => row.map((e) => e.toString()).toList()).toList();

      if (wordList.isNotEmpty) {
        updateWord();
      }
    } catch (e) {
      print('Error loading CSV: $e');
    }
  }

  /// Load game state for the current mode from SharedPreferences
  Future<void> loadState() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      currentWordIndex = prefs.getInt('currentWordIndex_$mode') ?? 0;
      currentLevel = prefs.getInt('currentLevel_$mode') ?? 1;
      wordsGuessed = prefs.getInt('wordsGuessed_$mode') ?? 0;
      correctGuessesInLevel = prefs.getInt('correctGuessesInLevel_$mode') ?? 0;

      print('Loaded state for $mode: WordIndex = $currentWordIndex, Level = $currentLevel');
      updateWord();
    } catch (e) {
      print('Error loading state: $e');
    }
  }

  /// Save the current game state for the current mode in SharedPreferences
  Future<void> saveState() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setInt('currentWordIndex_$mode', currentWordIndex);
      await prefs.setInt('currentLevel_$mode', currentLevel);
      await prefs.setInt('wordsGuessed_$mode', wordsGuessed);
      await prefs.setInt('correctGuessesInLevel_$mode', correctGuessesInLevel);

      print('Saved state for $mode: WordIndex = $currentWordIndex, Level = $currentLevel');
    } catch (e) {
      print('Error saving state: $e');
    }
  }

  /// Update current word and hint
  void updateWord() {
    if (currentWordIndex < wordList.length) {
      hint = wordList[currentWordIndex][1];
      word = wordList[currentWordIndex][0].toUpperCase();
    } else {
      hint = '';
      word = '';
    }
  }

  /// Increment the word index and update word
  void incrementWordIndex() {
    currentWordIndex++;
    updateWord();
  }

  /// Calculate points based on mode
  int calculatePoints() {
    switch (mode) {
      case 'easy':
        return 5;
      case 'medium':
        return 7;
      case 'hard':
        return 10;
      default:
        return 5;
    }
  }

  /// Save points to the database based on the mode
  Future<void> savePoints() async {
    final dbHelper = DatabaseHelper();
    if (isLevelBasedMode) {
      await dbHelper.insertOrUpdateByMode(mode, currentLevel, calculatePoints());
    } else {
      int indexLevel = _getIndexLevelFromMode(mode);
      await dbHelper.insertOrUpdateByIndex(indexLevel, calculatePoints());
    }
  }

  /// Map mode to index level
  int _getIndexLevelFromMode(String mode) {
    switch (mode) {
      case 'five':
        return 4;
      case 'six':
        return 5;
      case 'seven':
        return 6;
      default:
        return 0;
    }
  }
}
