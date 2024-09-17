import 'package:flutter/material.dart';
import 'package:word_guessing_app/View/bottom_navigation.dart';
import 'package:word_guessing_app/main.dart'; // Import the main file for buildAppBar
import 'package:word_guessing_app/view/word_guess_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyApp.buildAppBar(),  // Static AppBar
      body: MyApp.buildGradientBackground(
        child: FadeTransition(
          opacity: _animation,  // Only the body content fades in
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStyledButton(context, 'Easy', WordGuessScreen(mode: 'easy')),
                SizedBox(height: 25.0),
                _buildStyledButton(context, 'Medium', WordGuessScreen(mode: 'medium')),
                SizedBox(height: 25.0),
                _buildStyledButton(context, 'Hard', WordGuessScreen(mode: 'hard')),
              ],
            ),
          ),
        ),
      ),
      //bottomNavigationBar: BottomNavigation(currentIndex: 0),  // Static Bottom Navigation
    );
  }

  Widget _buildStyledButton(BuildContext context, String label, Widget page) {
    return Container(
      width: 200.0,
      height: 60.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getButtonGradientColors(label),
        ),
        borderRadius: BorderRadius.circular(7.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
            side: BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            _createPageTransition(page),
          );
        },
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getButtonGradientColors(String label) {
    switch (label) {
      case 'Easy':
        return [Color(0xFF13BB38), Color(0xFF43EA34)];
      case 'Medium':
        return [Color(0xFFFA9537), Color(0xFFEA6034)];
      case 'Hard':
        return [Color(0xFFFA3737), Color(0xFFBC0909)];
      default:
        return [Colors.grey, Colors.grey];
    }
  }

  PageRouteBuilder _createPageTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end);
        var offsetAnimation = animation.drive(tween.chain(CurveTween(curve: curve)));

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
