import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_guessing_app/achievement.dart';
import 'package:word_guessing_app/game_selection_screen.dart';
import 'package:word_guessing_app/index_selection_screen.dart';
import 'package:word_guessing_app/View/splash_screen.dart';
import 'package:word_guessing_app/view/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // Initialize AdMob
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
      title: 'KnoWord ',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: SplashScreenWrapper(),
    );
  }

  static AppBar buildAppBar({bool showBackButton = true}) {
    return AppBar(
      leading: showBackButton
          ? Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white, // Set the arrow color to white
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate to the previous screen
            },
          );
        },
      )
          : null,
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'KnoWord ',
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
}

class SplashScreenWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to MainScreen after a delay
    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0)),
      );
    });

    return Scaffold(
      body: SplashScreen(), // Ensure this widget is implemented correctly
    );
  }
}

class MainScreen extends StatefulWidget {
  final int selectedIndex;

  MainScreen({required this.selectedIndex});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    GameSelectionScreen(),
    AchievementScreen(),
    SettingsScreen(),
    IndexSelectionScreen(), // Example of a screen that needs a back button
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyApp.buildAppBar(
        showBackButton: _currentIndex == 3, // Show back button only for non-index screens
      ),
      body: MyApp.buildGradientBackground(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
