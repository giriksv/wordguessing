import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/word_controller.dart';
import '../model/word_model.dart';
import '../achievement.dart';

class WordGuessScreen extends StatefulWidget {
  final String mode;

  WordGuessScreen({required this.mode});

  @override
  _WordGuessScreenState createState() => _WordGuessScreenState();
}

class _WordGuessScreenState extends State<WordGuessScreen> {
  late WordController _controller;
  late WordModel _model;
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _model = WordModel(mode: widget.mode);
    _controller = WordController(_model);
    _controller.initialize().then((_) => setupTextFields());
  }

  void setupTextFields() {
    _controllers = List.generate(_model.word.length, (index) => TextEditingController());
    _focusNodes = List.generate(_model.word.length, (index) => FocusNode());

    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1) {
          FocusScope.of(context).requestFocus(getNextFocusNode(i + 1));
        }
      });
    }

    // Logic to display certain letters
    switch (_model.word.length) {
      case 5:
        _controllers[1].text = _model.word[1];
        _controllers[3].text = _model.word[3];
        break;
      case 6:
        _controllers[2].text = _model.word[2];
        _controllers[4].text = _model.word[4];
        break;
      case 7:
        _controllers[2].text = _model.word[2];
        _controllers[5].text = _model.word[5];
        break;
      case 8:
        _controllers[1].text = _model.word[1];
        _controllers[3].text = _model.word[3];
        _controllers[6].text = _model.word[6];
        break;
      default:
        if (_model.word.length > 8) {
          _controllers[1].text = _model.word[1];
          _controllers[5].text = _model.word[5];
          _controllers[6].text = _model.word[6];
        }
    }

    setState(() {});
  }

  FocusNode getNextFocusNode(int index) {
    if (index < _focusNodes.length) {
      return _focusNodes[index];
    }
    return _focusNodes.last;
  }

  void _checkAnswer() {
    String guessedWord = _controllers.map((c) => c.text.toUpperCase()).join();

    _controller.checkAnswer(guessedWord, (bool levelCompleted) {
      if (levelCompleted) {
        _showLevelCompleteDialog();
      } else {
        _showCorrectAnswerDialog();
      }
    }, () {
      _showIncorrectAnswerDialog();
    });
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Level Complete'),
        content: Text('You have completed Level ${_model.currentLevel}.'),
        actions: [
          TextButton(
            onPressed: () {
              setupTextFields();
              Navigator.of(context).pop();
            },
            child: Text('Next Level'),
          ),
        ],
      ),
    );
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Correct!'),
        content: Text('You guessed the word correctly.'),
        actions: [
          TextButton(
            onPressed: () {
              setupTextFields();
              Navigator.of(context).pop();
            },
            child: Text('Next Word'),
          ),
        ],
      ),
    );
  }

  void _showIncorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incorrect!'),
        content: Text('The correct word was ${_model.word}.'),
        actions: [
          TextButton(
            onPressed: () {
              setupTextFields();
              Navigator.of(context).pop();
            },
            child: Text('Next Word'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guess the Word'),
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AchievementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hint: ${_model.hint}',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 24.0),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _model.word.length,
                childAspectRatio: 1.0,
              ),
              itemCount: _model.word.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    style: TextStyle(fontSize: 32.0),
                  ),
                );
              },
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: Text('Check Answer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    _controller.saveState();
    super.dispose();
  }
}
