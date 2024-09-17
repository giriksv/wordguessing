import 'package:flutter/material.dart';
import 'package:word_guessing_app/View/PrivacyPolicyScreen.dart';
import 'package:word_guessing_app/View/TermsAndCondition.dart';
import 'package:word_guessing_app/View/bottom_navigation.dart';
import 'package:word_guessing_app/main.dart'; // Import the main file to use buildAppBar and buildGradientBackground

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: MyApp.buildAppBar(), // Use the AppBar from main.dart
      body: MyApp.buildGradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              title: Text(
                'Privacy Policy',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                );
              },
            ),
            Divider(color: Colors.white), // Optional: Set the divider color to white
            ListTile(
              title: Text(
                'Terms and Conditions',
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Termsandcondition()),
                );
              },
            ),
           // Divider(color: Colors.white), // Optional: Set the divider color to white
            // ListTile(
            //   title: Text(
            //     'About Us',
            //     style: TextStyle(color: Colors.white), // Set text color to white
            //   ),
            //   onTap: () {
            //     // Implement action for About Us
            //   },
            // ),
          ],
        ),
      ),
      //bottomNavigationBar: BottomNavigation(currentIndex: 0),

      // bottomNavigationBar: MyApp.buildBottomNavigationBar(
      //   currentIndex: 2, // Index for the Settings tab
      //   onTap: (index) {
      //     // Handle navigation based on selected index
      //     Navigator.pushReplacementNamed(
      //       context,
      //       index == 0 ? '/gameSelection' :
      //       index == 1 ? '/achievement' :
      //       '/settings', // Use the correct route for settings
      //     );
      //   },
      // ),
    );
  }
}
