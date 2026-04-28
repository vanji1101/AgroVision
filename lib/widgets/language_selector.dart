import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.language, color: AppColors.primaryGreen, size: 24),
      ),
      onSelected: (String languageCode) {
        languageProvider.setLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Text(
                'English',
                style: TextStyle(
                  fontWeight: languageProvider.currentLocale.languageCode == 'en' 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                  color: languageProvider.currentLocale.languageCode == 'en' 
                      ? AppColors.primaryGreen 
                      : AppColors.textPrimary,
                ),
              ),
              if (languageProvider.currentLocale.languageCode == 'en')
                const Spacer(),
              if (languageProvider.currentLocale.languageCode == 'en')
                const Icon(Icons.check, color: AppColors.primaryGreen, size: 18),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'ta',
          child: Row(
            children: [
              Text(
                'தமிழ் (Tamil)',
                style: TextStyle(
                  fontWeight: languageProvider.currentLocale.languageCode == 'ta' 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                  color: languageProvider.currentLocale.languageCode == 'ta' 
                      ? AppColors.primaryGreen 
                      : AppColors.textPrimary,
                ),
              ),
              if (languageProvider.currentLocale.languageCode == 'ta')
                const Spacer(),
              if (languageProvider.currentLocale.languageCode == 'ta')
                const Icon(Icons.check, color: AppColors.primaryGreen, size: 18),
            ],
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
