import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/language_provider.dart';
import 'home_screen.dart';
import 'market_screen.dart';
import 'voice_ai_screen.dart';
import 'seed_fertilizer_screen.dart';
import 'profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    MarketScreen(),
    VoiceAIScreen(), // Reusing VoiceAIScreen as Chat
    SeedFertilizerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: lp.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart_outlined),
            label: lp.translate('market'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            label: lp.translate('chat'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            label: lp.translate('seeds'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: lp.translate('profile'),
          ),
        ],
      ),
    );
  }
}
