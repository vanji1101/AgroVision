import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _showLanguageDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.translate('change_language')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, 'en', languageProvider.translate('english')),
            _languageOption(context, 'ta', languageProvider.translate('tamil')),
            _languageOption(context, 'hi', languageProvider.translate('hindi')),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, String code, String label) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: code,
        groupValue: languageProvider.currentLocale.languageCode,
        activeColor: AppColors.primaryGreen,
        onChanged: (value) {
          if (value != null) {
            languageProvider.setLanguage(value);
            Navigator.pop(context);
          }
        },
      ),
      onTap: () {
        languageProvider.setLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(lp.translate('settings'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('App Preferences'),
          _settingsCard([
            InkWell(
              onTap: () => _showLanguageDialog(context),
              child: _settingsItem(
                Icons.language,
                lp.translate('language'),
                lp.currentLocale.languageCode == 'en'
                    ? lp.translate('english')
                    : lp.currentLocale.languageCode == 'ta'
                        ? lp.translate('tamil')
                        : lp.translate('hindi'),
                Icons.arrow_forward_ios,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.notifications_none, color: AppColors.primaryGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Notifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        Text('Get alerts for weather and prices', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                    activeThumbColor: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionHeader('Support'),
          _settingsCard([
            _settingsItem(Icons.help_outline, 'Help & FAQ', '', Icons.arrow_forward_ios),
            const Divider(height: 1),
            _settingsItem(Icons.contact_support_outlined, 'Contact Support', '', Icons.arrow_forward_ios),
          ]),
          const SizedBox(height: 16),
          _sectionHeader('About'),
          _settingsCard([
            _settingsItem(Icons.info_outline, 'App Version', 'v1.0.0', null),
            const Divider(height: 1),
            _settingsItem(Icons.description_outlined, 'Terms & Privacy', '', Icons.arrow_forward_ios),
          ]),
          const SizedBox(height: 32),
          const Center(
            child: Text('© 2026 AgroVision. All rights reserved.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }

  Widget _settingsItem(IconData icon, String title, String value, IconData? trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
          if (value.isNotEmpty)
            Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Icon(trailing, size: 14, color: Colors.grey.shade400),
          ],
        ],
      ),
    );
  }
}
