import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Notifications', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text('அறிவிப்புகள்', style: TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _notificationCard(
            Icons.wb_cloudy_outlined,
            'Heavy Rain Alert',
            'கனமழை எச்சரிக்கை',
            'Expected tomorrow — protect your crops',
            'நாளை எதிர்பார்க்கப்படுகிறது — பயிர்களை பாதுகாக்கவும்',
            '2 hours ago',
            AppColors.orange,
          ),
          _notificationCard(
            Icons.trending_up,
            'Rice Price Increased',
            'நெல் விலை உயர்வு',
            '₹3,400/quintal (+15% from last week)',
            '₹3,400/குவிண்டால் (கடந்த வாரத்திலிருந்து +15%)',
            '5 hours ago',
            Colors.green,
          ),
          _notificationCard(
            Icons.account_balance_outlined,
            'New Scheme Available',
            'புதிய திட்டம் கிடைக்கிறது',
            'PM-KISAN payment is now available',
            'பிரதமர் கிசான் கட்டணம் இப்போது கிடைக்கிறது',
            '1 day ago',
            AppColors.orange,
          ),
          _notificationCard(
            Icons.cloud_done_outlined,
            'Weather Update',
            'வானிலை புதுப்பிப்பு',
            'Partly cloudy conditions expected',
            'பகுதியளவு மேகமூட்டம் எதிர்பார்க்கப்படுகிறது',
            '1 day ago',
            AppColors.blue,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _notificationCard(IconData icon, String title, String tamilTitle, String body, String tamilBody, String time, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                Text(tamilTitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text(body, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                Text(tamilBody, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
