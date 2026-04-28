import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CropDiseaseScreen extends StatelessWidget {
  const CropDiseaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Crop Disease Detection',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text('பயிர் நோய் கண்டறிதல்',
              style: TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Upload Crop Image',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Take a clear photo of affected leaves or crop',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              const Text('பாதிக்கப்பட்ட இலைகளின் தெளிவான புகைப்படம் எடுக்கவும்',
                  style: TextStyle(fontSize: 12, color: AppColors.textOrange)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _uploadOption(Icons.camera_alt_outlined, 'Camera', 'கேமரா')),
                  const SizedBox(width: 14),
                  Expanded(child: _uploadOption(Icons.photo_library_outlined, 'Gallery', 'தொகுப்பு')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadOption(IconData icon, String label, String tamil) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.lightGreenBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primaryGreen,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.primaryGreen, size: 36),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
          const SizedBox(height: 2),
          Text(tamil, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}
