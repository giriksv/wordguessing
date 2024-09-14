import 'package:flutter/material.dart';
import 'package:word_guessing_app/main.dart'; // Import MyApp to access the AppBar and background methods

class PrivacyPolicyScreen extends StatelessWidget {
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
                _buildSectionTitle('What do we collect :'),
                _buildContentText(
                    'We do not collect any user input, except for the missing letters in the word. '
                        'Our goal is to assist users in learning English words. We will never collect your '
                        'personal or non-personal information with anyone, except as outlined in this privacy policy.'),
                SizedBox(height: 18),
                _buildSectionTitle('Do we transfer any information to outside parties?'),
                _buildContentText(
                    'Since we do not collect any user information, either directly or indirectly, '
                        'we have no user data to share with others. The only input we receive is alphabetic '
                        'letters, which are used solely to check if the guessed word is correct.'),
                SizedBox(height: 16),
                _buildSectionTitle('Third party links :'),
                _buildContentText(
                    'Occasionally, at our discretion, we may include or offer third-party products or services on '
                        'our app via ads (Admob). These third-party sites have separate and independent privacy policies. '
                        'We, therefore, have no responsibility or liability for the content and activities of these linked '
                        'sites. Please read the privacy policy of Admob by using this link. '
                        'https://support.google.com/admob/answer/6128543?hl=en'),
                SizedBox(height: 16),
                _buildSectionTitle('Advertisement in App:'),
                _buildContentText(
                    'We use Google Admob to display an ad in our application. There could be errors in the programming '
                        'and sometimes programming errors may cause unwanted side effects. Also to know about Google Ads '
                        'Privacy Policy Click and jump to: Google ad privacy policy.'),
                SizedBox(height: 16),
                _buildSectionTitle('Storage :'),
                _buildContentText(
                    'We store all points locally in an SQLite database on your device. This application does not transfer '
                        'any information to other networked systems. User points (achievements) are stored exclusively in '
                        'the local database on your device.'),
                SizedBox(height: 16),
                _buildSectionTitle('Deletion of Data :'),
                _buildContentText(
                    'Achievements (points) are stored only in the local database on your mobile device. Users can delete '
                        'the points stored in the local database by uninstalling the application, which will remove all data from the device.'),
                SizedBox(height: 16),
                _buildSectionTitle('Do we use cookies?'),
                _buildContentText('No, We do not use cookies.'),
                SizedBox(height: 16),
                _buildSectionTitle('Do we sell your data?'),
                _buildContentText(
                    'No, we have never sold your data. The data (points) are stored exclusively in the local SQLite database on your mobile device. '
                        'We cannot read, edit, or access the data stored in your device\'s local database.'),
                SizedBox(height: 16),
                _buildSectionTitle('Changes to our Privacy Policy:'),
                _buildContentText(
                    'If we decide to make changes to our privacy policy, we will post the updates on this page and within our application. '
                        'This policy was last modified on September 14, 2024.'),
                SizedBox(height: 16),
                _buildSectionTitle('Contacting Us:'),
                _buildContentText(
                    'If there are any questions regarding our privacy policy you may contact us using the information below.\n\n'
                        'Email: zealtown22@gmail.com'),
              ],
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
