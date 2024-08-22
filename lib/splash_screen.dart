import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'game_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    // Define a fade-in animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start the fade-in after a delay of 1 second
    Future.delayed(Duration(seconds: 1), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Display the SVG image
          SvgPicture.asset(
            'assets/image/splash.svg',
            fit: BoxFit.cover,
          ),
          // Fade in the text and button within a SafeArea
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Use Flex to adjust layout
                Expanded(
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display the word "WordGame" with the Lobster font and white border
                      Center(
                        child: Text(
                          'WordGame',
                          style: TextStyle(
                            fontFamily: 'Lobster',
                            fontSize: 48.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            letterSpacing: 0.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 15.0),
                      // Display the "PLAY NOW" button with bold text
                      Center(
                        child: FadeTransition(
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
                              // Navigate to GameSelectionScreen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => GameSelectionScreen()),
                              );
                            },
                            child: Text(
                              'PLAY NOW !',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25.4,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
            ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
