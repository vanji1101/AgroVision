import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 70,
        width: 70,
        margin: const EdgeInsets.only(top: 20),
        child: FloatingActionButton(
          onPressed: () => setState(() => _currentIndex = 2),
          backgroundColor: AppColors.primaryGreen,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.home_outlined, lp.translate('home')),
              _buildNavItem(1, Icons.shopping_cart_outlined, lp.translate('market')),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(3, Icons.inventory_2_outlined, lp.translate('seeds')),
              _buildNavItem(4, Icons.person_outline, lp.translate('profile')),
            ],
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
