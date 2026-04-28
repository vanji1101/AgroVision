import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SoilAnalysisScreen extends StatelessWidget {
  const SoilAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.soilBrown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Soil Analysis', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('மண் பகுப்பாய்வு', style: TextStyle(fontSize: 11, color: Colors.white70)),
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
              const Text('Upload Soil Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Upload your soil test report or enter details manually',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              const Text('மண் சோதனை அறிக்கையை பதிவேற்றவும்',
                  style: TextStyle(fontSize: 12, color: AppColors.textOrange)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF5EF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.soilBrown, width: 1.5),
                  ),
                  child: Column(children: const [
                    Icon(Icons.upload_outlined, color: AppColors.soilBrown, size: 40),
                    SizedBox(height: 10),
                    Text('Upload Report',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.soilBrown)),
                    SizedBox(height: 4),
                    Text('அறிக்கையை பதிவேற்றவும்',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
