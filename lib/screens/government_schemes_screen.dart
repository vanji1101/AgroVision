import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GovernmentSchemesScreen extends StatelessWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Government Schemes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text('அரசு திட்டங்கள்', style: TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _schemeCard(
            'PM-KISAN',
            'பிரதமர் கிசான் திட்டம்',
            '₹6,000/year direct cash transfer',
            'ஆண்டுக்கு ₹6,000 நேரடி பணம்',
            'All farmers with cultivable land',
            ['Aadhaar Card', 'Land Records', 'Bank Account'],
            Colors.green,
          ),
          _schemeCard(
            'Pradhan Mantri Fasal Bima Yojana',
            'பிரதமர் பயிர் காப்பீடு திட்டம்',
            'Crop insurance at 2% premium',
            '2% பிரீமியத்தில் பயிர் காப்பீடு',
            'Farmers & tenant farmers',
            ['Aadhaar', 'Land Ownership/Lease Proof', 'Bank Account'],
            Colors.blue,
          ),
          _schemeCard(
            'Soil Health Card Scheme',
            'மண் ஆரோக்கிய அட்டை திட்டம்',
            'Free soil testing & recommendations',
            'இலவச மண் சோதனை & பரிந்துரைகள்',
            'All farmers',
            ['Aadhaar Card', 'Land Records'],
            Colors.orange,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _schemeCard(String title, String tamilTitle, String benefits, String tamilBenefits, String eligibility, List<String> docs, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.check_circle_outline, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(tamilTitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Benefits', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                Text(benefits, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(tamilBenefits, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Eligibility', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Text(eligibility, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          const Text('Required Documents', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 8,
            children: docs.map((doc) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 6, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(doc, style: const TextStyle(fontSize: 12)),
              ],
            )).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Apply Now', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
