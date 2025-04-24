import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_drawer.dart';
import 'language_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Settings')),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate('Appearance'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<ThemeProvider>(
                      builder: (ctx, themeProvider, _) => SwitchListTile(
                        title: Text(translate('Dark Mode')),
                        subtitle: Text(translate('Switch between light and dark theme')),
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        secondary: Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Language Settings
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate('Language'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(translate('Change Language')),
                      subtitle: Text(
                        languageProvider.supportedLanguages
                            .firstWhere(
                              (lang) => lang['code'] == languageProvider.currentLocale.languageCode,
                              orElse: () => {'name': 'English', 'nativeName': 'English'},
                            )['nativeName']!,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      leading: const Icon(Icons.translate),
                      onTap: () {
                        Navigator.of(context).pushNamed(LanguageScreen.routeName);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate('Notifications'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(translate('Expiry Alerts')),
                      subtitle: Text(translate('Get notified when items are about to expire')),
                      value: true, // This would be connected to a provider
                      onChanged: (_) {
                        // This would toggle notification settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(translate('Feature coming soon')),
                          ),
                        );
                      },
                      secondary: const Icon(Icons.notifications_active),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate('About'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(translate('Version')),
                      subtitle: const Text('1.0.0'),
                      leading: const Icon(Icons.info_outline),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(translate('Privacy Policy')),
                      leading: const Icon(Icons.privacy_tip_outlined),
                      onTap: () {
                        // Navigate to privacy policy
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(translate('Send Feedback')),
                      leading: const Icon(Icons.feedback_outlined),
                      onTap: () {
                        // Open feedback form
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}