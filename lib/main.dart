import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_guessing_app/splash_screen.dart';
import 'package:word_guessing_app/game_selection_screen.dart';
import 'package:word_guessing_app/achievement.dart';
import 'package:word_guessing_app/mode_selection_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const LinearGradient appBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0083CB),
      Color(0xFF01D4CA),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Guessing App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: SplashScreenWrapper(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/gameSelection':
            return MaterialPageRoute(
              builder: (context) => MainScreen(
                selectedIndex: 0,
                child: GameSelectionScreen(),
              ),
            );
          case '/achievement':
            return MaterialPageRoute(
              builder: (context) => MainScreen(
                selectedIndex: 1,
                child: AchievementScreen(),
              ),
            );
          case '/modeSelection':
            return MaterialPageRoute(
              builder: (context) => MainScreen(
                selectedIndex: 2,
                child: ModeSelectionScreen(),
              ),
            );
          default:
            return MaterialPageRoute(builder: (context) => SplashScreenWrapper());
        }
      },
    );
  }

  static AppBar buildAppBar() {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'Word Game',
          style: GoogleFonts.lobster(
            textStyle: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.0,
            ),
          ),
        ),
      ),
      centerTitle: true,
      backgroundColor: Color(0xFF0083CB),
      toolbarHeight: 100.0,
    );
  }

  static Container buildGradientBackground({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: appBackgroundGradient,
      ),
      child: child,
    );
  }

  static BottomNavigationBar buildBottomNavigationBar({
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Achievement',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue[800],
      backgroundColor: Color(0xFFC6EEEE),
      onTap: onTap,
    );
  }
}

class SplashScreenWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashScreen(),
      bottomNavigationBar: MyApp.buildBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          Navigator.pushReplacementNamed(
            context,
            index == 0 ? '/gameSelection' : index == 1 ? '/achievement' : '/modeSelection',
          );
        },
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  final int selectedIndex;
  final Widget child;

  MainScreen({required this.selectedIndex, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyApp.buildAppBar(),
      body: MyApp.buildGradientBackground(child: child),
      bottomNavigationBar: MyApp.buildBottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          Navigator.pushReplacementNamed(
            context,
            index == 0 ? '/gameSelection' : index == 1 ? '/achievement' : '/modeSelection',
          );
        },
      ),
    );
  }
}
