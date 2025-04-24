import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final translate = languageProvider.getTranslatedValue;
    
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: translate('Change Language'),
      onSelected: (languageCode) {
        languageProvider.setLanguage(languageCode);
      },
      itemBuilder: (ctx) => languageProvider.supportedLanguages
          .map(
            (language) => PopupMenuItem<String>(
              value: language['code'],
              child: Row(
                children: [
                  Text(
                    language['flag'] ?? '',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(language['nativeName'] ?? language['name'] ?? ''),
                  const Spacer(),
                  if (languageProvider.currentLanguageCode == language['code'])
                    Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                    ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}