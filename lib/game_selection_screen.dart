import 'package:flutter/material.dart';
import 'package:word_guessing_app/View/bottom_navigation.dart';
import 'package:word_guessing_app/main.dart'; // Import the main file for buildAppBar
import 'package:word_guessing_app/view/word_guess_screen.dart';
import 'index_selection_screen.dart';
import 'mode_selection_screen.dart';

class GameSelectionScreen extends StatefulWidget {
  @override
  _GameSelectionScreenState createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> with SingleTickerProviderStateMixin {
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
      // appBar: MyApp.buildAppBar(),
      body: MyApp.buildGradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStyledButton(context, 'By Mode', ModeSelectionScreen()),
              SizedBox(height: 45.0),
              _buildStyledButton(context, 'By Letter', IndexSelectionScreen()),
              SizedBox(height: 45.0),
              _buildStyledButton(context, 'Free Play', WordGuessScreen(mode: 'Free Play')),
            ],
          ),
        ),
      ),
     // bottomNavigationBar: BottomNavigation(currentIndex: 0),

    );
  }

  Widget _buildStyledButton(BuildContext context, String label, Widget page) {
    return FadeTransition(
      opacity: _animation,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
            side: BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          fixedSize: Size(200.0, 60.0),
        ),
        onPressed: () {
          Navigator.push(
            context,
            _createPageTransition(page),
          );
        },
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
