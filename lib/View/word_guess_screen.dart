import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:word_guessing_app/View/bottom_navigation.dart';
import 'package:word_guessing_app/achievement.dart';
import 'package:word_guessing_app/main.dart';
import 'package:word_guessing_app/model/database_helper.dart';
import '../controller/word_controller.dart';
import '../model/word_model.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';


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
  int totalPoints = 0;
  //InterstitialAd? _interstitialAd;
  int _clickCount = 0; // Counter to track button clicks
  final String adUnitId = 'ca-app-pub-3940256099942544/1033173712';
  //our adunitid
  //final String adUnitId = 'ca-app-pub-5890010862725643/9887441454';


  @override
  void initState() {
    super.initState();
    _model = WordModel(mode: widget.mode);
    _controller = WordController(_model);
    _controller.initialize().then((_) {
      setupTextFields();
      _fetchTotalPoints();
      //_createInterstitialAd(); // Load the ad on screen initialization

    });
  }

  Future<void> _fetchTotalPoints() async {
    final dbHelper = DatabaseHelper();
    final points = await dbHelper.getTotalPoints();
    setState(() {
      totalPoints = points['total'] ?? 0;
    });
  }

  Future<void> _updatePoints(int points) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertOrUpdateByMode(widget.mode, _model.currentLevel, points);
    await _fetchTotalPoints();
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
  // void _createInterstitialAd() {
  //   InterstitialAd.load(
  //     adUnitId: adUnitId,
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (InterstitialAd ad) {
  //         _interstitialAd = ad;
  //         _interstitialAd?.setImmersiveMode(true);
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         print('InterstitialAd failed to load: $error');
  //       },
  //     ),
  //   );
  // }
  // void _showInterstitialAd() {
  //   if (_interstitialAd != null) {
  //     _interstitialAd?.show();
  //     _interstitialAd = null; // Reset after showing ad
  //     _createInterstitialAd(); // Load a new ad for next use
  //   }
  // }
  // Call this method on button click
  // void _handleButtonClick() {
  //   setState(() {
  //     _clickCount++;
  //   });
  //
  //   if (_clickCount == 3) {
  //     _showInterstitialAd();
  //     _clickCount = 0; // Reset the click counter
  //   }
  //
  //   // Add your button click logic here
  // }
  @override
  void dispose() {
    //_interstitialAd?.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    String guessedWord = _controllers.map((c) => c.text.toUpperCase()).join();
    //_handleButtonClick(); // Correctly call the method

    _controller.checkAnswer(guessedWord, (bool levelCompleted) {
      if (levelCompleted) {
        _updatePoints(10);
        _showLevelCompleteDialog();
      } else {
        _updatePoints(5);
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
        backgroundColor: Colors.transparent, // Make background transparent
        contentPadding: EdgeInsets.zero, // Remove default padding
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0083CB), Color(0xFF01D4CA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 30),
                    SizedBox(width: 10),
                    Text('Correct!', style: TextStyle(color: Colors.white, fontSize: 24)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'You guessed the word correctly.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextButton(
                  onPressed: () {
                    setupTextFields();
                    Navigator.of(context).pop();
                  },
                  child: Text('Next Word', style: TextStyle(color: Colors.yellow)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIncorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent, // Make background transparent
        contentPadding: EdgeInsets.zero, // Remove default padding
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFA9537), Color(0xFFEA6034)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.white70, size: 30),
                    SizedBox(width: 10),
                    Text('Incorrect !', style: TextStyle(color: Colors.white, fontSize: 24)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'The correct word was ${_model.word}.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextButton(
                  onPressed: () {
                    setupTextFields();
                    Navigator.of(context).pop();
                  },
                  child: Text('Next Word', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyApp.buildAppBar(),
      body: Container(
        constraints: BoxConstraints.expand(), // Ensure container expands to full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0083CB), Color(0xFF01D4CA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding on all sides
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Points container positioned in the right corner
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => AchievementScreen()),
                    //   );
                    // },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monetization_on, color: Colors.yellow),
                        SizedBox(width: 8.0),
                        Text(
                          '$totalPoints',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 75.0),

              // Expanded widget to take remaining space
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // "Find the word" text
                      Center(
                        child: Text(
                          'Find the word',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // SizedBox to add spacing below "Find the word"
                      SizedBox(height: 75.0),

                      // Text Fields for word input
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_model.word.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    width: 50.0, // Fixed width of the container
                                    height: 50.0, // Fixed height of the container
                                    decoration: BoxDecoration(
                                      color: Colors.white, // White background for the container
                                      borderRadius: BorderRadius.circular(8.0), // Curved edges
                                      border: Border.all(color: Colors.black), // Black border
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        textAlign: TextAlign.center,
                                        textCapitalization: TextCapitalization.characters,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(1),
                                        ],
                                        decoration: InputDecoration(
                                          border: InputBorder.none, // Remove the default border
                                          contentPadding: EdgeInsets.zero, // No padding inside the text field
                                        ),
                                        style: TextStyle(
                                          fontSize: 16.0, // Adjusted font size for the letter
                                          color: Colors.black, // Text color
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (_model.word.length > 6) // Show arrows only if the word length is greater than 7
                              Positioned(
                                left: 0,
                                child: Icon(Icons.arrow_forward_ios, color: Colors.black),
                              ),
                            if (_model.word.length > 6)
                              Positioned(
                                right: 0,
                                child: Icon(Icons.arrow_back_ios, color: Colors.black),
                              ),
                          ],
                        ),
                      ),

                      // SizedBox to add spacing before the submit button
                      SizedBox(height: 50),

                      // Hint text in white color
                      Text(
                        ' ${_model.hint}',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // SizedBox to add spacing before the submit button
                      SizedBox(height: 50.0),

                      // Submit button
                      Center(
                        child: ElevatedButton(
                          onPressed: _checkAnswer,

                          child: Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.yellow, padding: EdgeInsets.symmetric(
                            horizontal: 50.0,
                            vertical: 16.0,
                          ),
                            textStyle: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ), // Black text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // Rounded edges
                              side: BorderSide(color: Colors.black), // Black border
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      //bottomNavigationBar: BottomNavigation(currentIndex: 0),

    );
  }

}
