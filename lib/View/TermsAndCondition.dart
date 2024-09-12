import 'package:flutter/material.dart';
import 'package:word_guessing_app/main.dart'; // Import MyApp to access the AppBar and background methods

class Termsandcondition extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyApp.buildAppBar(showBackButton: true), // Use the shared AppBar
      body: MyApp.buildGradientBackground( // Use the shared gradient background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Description of Service :'),
                _buildContentText(
                    'The KnoWord application provides various types of implementation of a game By mode, By letter count and free play. '),
                SizedBox(height: 18),
                _buildSectionTitle('No Permissions Required :'),
                _buildContentText(
                    'You do not need to grant any permissions to access or use the KnoWord application. We do not require access to any personal information or data on your device.'),
                SizedBox(height: 16),
                _buildSectionTitle('Disclaimer : '),
                _buildContentText(
                    'The word guessing application is designed for educational and entertainment purposes only. While we strive to provide accurate word definitions and hints, we do not guarantee the completeness, accuracy, or reliability of the information provided. The app is intended to help users improve their vocabulary and language skills, but it should not be relied upon as a sole learning resource.'),
                SizedBox(height: 16),
                _buildSectionTitle('Changes to our Terms of service:'),
                _buildContentText(
                    'If we decide to update our Terms of Service, we will post the changes on this page and within our application.'
                    'This policy was last modified on September 9, 2024.'),
                SizedBox(height: 16),
                _buildSectionTitle('Contact Us : '),
                _buildContentText(
                    'If you have any questions or concerns about these Terms, please contact us at zingtekinnovations@gmail.com'
                    'By using the KnoWord application, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service'),
                SizedBox(height: 16),              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        //color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  Widget _buildContentText(String content) {
    return Text(
      content,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }
}
