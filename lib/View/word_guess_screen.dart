import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Model/word_model.dart';
import 'achievement.dart';

class WordGuessScreen extends StatefulWidget {
  final String mode;

  WordGuessScreen({required this.mode});

  @override
  _WordGuessScreenState createState() => _WordGuessScreenState();
}

class _WordGuessScreenState extends State<WordGuessScreen> {
  late WordModel wordModel;
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    wordModel = WordModel();
    wordModel.isLevelBasedMode = ['easy', 'medium', 'hard'].contains(widget.mode);

    if (widget.mode == 'Free Play') {
      wordModel.isLevelBasedMode = false;
    }

    wordModel.loadCSV(widget.mode).then((_) => wordModel.loadState(widget.mode)).then((_) {
      setState(() {
        setupTextFields();
      });
    });
  }

  void setupTextFields() {
    controllers = List.generate(wordModel.word.length, (index) => TextEditingController());
    focusNodes = List.generate(wordModel.word.length, (index) => FocusNode());

    for (int i = 0; i < controllers.length; i++) {
      controllers[i].addListener(() {
        if (controllers[i].text.length == 1) {
          FocusScope.of(context).requestFocus(getNextFocusNode(i + 1));
        }
      });
    }

    if (wordModel.word.length >= 5) {
      controllers[2].text = wordModel.word[2];
      controllers[4].text = wordModel.word[4];
    }
    if (wordModel.word.length >= 7) {
      controllers[6].text = wordModel.word[6];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(getNextFocusNode(0));
    });
  }

  FocusNode getNextFocusNode(int index) {
    if (index < focusNodes.length) {
      return focusNodes[index];
    }
    return focusNodes.last;
  }

  void checkAnswer() async {
    String guessedWord = controllers.map((c) => c.text.toUpperCase()).join();

    if (guessedWord == wordModel.word) {
      int points = 0;
      switch (widget.mode) {
        case 'easy':
          points = 5;
          break;
        case 'medium':
          points = 7;
          break;
        case 'hard':
          points = 10;
          break;
        default:
          points = 5;
          break;
      }

      await wordModel.savePoints(points, widget.mode, wordModel.currentLevel);

      if (wordModel.isLevelBasedMode) {
        if ((wordModel.currentLevel * 10) % 10 == 0) {
          _showLevelCompleteDialog();
        } else {
          _showCorrectAnswerDialog();
        }
      } else {
        _nextWord();
      }
    } else {
      _showIncorrectAnswerDialog();
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Level Complete', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('You have completed Level ${wordModel.currentLevel}.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                wordModel.currentLevel++;
                wordModel.currentWordIndex++;
                wordModel.updateWord();
                setupTextFields();
              });
              wordModel.saveState(widget.mode);
              Navigator.of(context).pop();
            },
            child: Text('Next Level', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Correct!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('You guessed the word correctly.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                wordModel.currentWordIndex++;
                wordModel.updateWord();
                setupTextFields();
              });
              wordModel.saveState(widget.mode);
              Navigator.of(context).pop();
            },
            child: Text('Next Word', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showIncorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incorrect!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('The correct word was ${wordModel.word}.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                wordModel.currentWordIndex++;
                wordModel.updateWord();
                setupTextFields();
              });
              wordModel.saveState(widget.mode);
              Navigator.of(context).pop();
            },
            child: Text('Next Word', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _nextWord() {
    setState(() {
      wordModel.currentWordIndex++;
      if (wordModel.currentWordIndex >= wordModel.wordList.length) {
        wordModel.currentWordIndex = 0;
      }
      wordModel.updateWord();
      setupTextFields();
    });
    wordModel.saveState(widget.mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Guessing Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AchievementScreen()),
              );
            },
          ),
        ],
      ),
      body: wordModel.wordList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hint: ${wordModel.hint.toLowerCase()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            SizedBox(height: 20),
            Row(
              children: List.generate(wordModel.word.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      inputFormatters: [UpperCaseTextFormatter()],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text('Submit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
