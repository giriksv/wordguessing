// import 'package:flutter/material.dart';
// import 'package:word_guessing_app/achievement.dart';
// import 'package:word_guessing_app/game_selection_screen.dart';
// import 'settings_screen.dart';
//
// class BottomNavigation extends StatefulWidget {
//   final int currentIndex;
//
//   BottomNavigation({this.currentIndex = 0});
//
//   @override
//   _BottomNavigationState createState() => _BottomNavigationState();
// }
//
// class _BottomNavigationState extends State<BottomNavigation> {
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: widget.currentIndex,
//       items: [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.safety_check),
//           label: 'Achievements',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.settings),
//           label: 'Settings',
//         ),
//       ],
//       onTap: (index) {
//         switch (index) {
//           case 0:
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => GameSelectionScreen()),
//             );
//             break;
//           case 1:
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => AchievementScreen()),
//             );
//             break;
//           case 2:
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => SettingsScreen()),
//             );
//             break;
//         }
//       },
//     );
//   }
// }
