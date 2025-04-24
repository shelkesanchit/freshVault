import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_drawer.dart';

class LanguageScreen extends StatelessWidget {
  static const routeName = '/language';
  
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Language')),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: languageProvider.supportedLanguages.length,
        itemBuilder: (ctx, index) {
          final language = languageProvider.supportedLanguages[index];
          final isSelected = language['code'] == languageProvider.currentLanguageCode;
          
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
            child: ListTile(
              leading: Text(
                language['flag'] ?? '',
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                language['nativeName'] ?? language['name'] ?? '',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : null,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
              subtitle: Text(language['name'] ?? ''),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () {
                languageProvider.setLanguage(language['code'] ?? 'en');
              },
            ),
          );
        },
      ),
    );
  }
}