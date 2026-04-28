import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_network_image.dart';

class SeedsScreen extends StatefulWidget {
  const SeedsScreen({super.key});
  @override
  State<SeedsScreen> createState() => _SeedsScreenState();
}

class _SeedsScreenState extends State<SeedsScreen> {
  String _filter = 'All';
  final List<String> _filters = ['All', 'Rice', 'Wheat', 'Cotton', 'Other'];

  final List<_Seed> _seeds = [
    _Seed('Rice Seeds - IR64', 'https://images.unsplash.com/photo-1536679545597-c2e5e1946495?auto=format&fit=crop&q=80&w=200', '₹1200 /25kg', 'Rice', 'Amazon'),
    _Seed('Wheat Seeds - HD3086', 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&q=80&w=200', '₹850 /25kg', 'Wheat', 'Flipkart'),
    _Seed('Cotton Seeds - Bt', 'https://images.unsplash.com/photo-1594903582424-814643b97051?auto=format&fit=crop&q=80&w=200', '₹2400 /10kg', 'Cotton', 'Amazon'),
    _Seed('Tomato Seeds - Hybrid', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&q=80&w=200', '₹450 /500g', 'Other', 'Flipkart'),
    _Seed('Chilli Seeds - G4', 'https://images.unsplash.com/photo-1588252303782-cb80119f702e?auto=format&fit=crop&q=80&w=200', '₹380 /500g', 'Other', 'Amazon'),
    _Seed('Corn Seeds - Hybrid', 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?auto=format&fit=crop&q=80&w=200', '₹680 /10kg', 'Other', 'Flipkart'),
  ];

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    final visible = _filter == 'All' ? _seeds : _seeds.where((s) => s.category == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(lp.translate('seeds'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: _filters.map((f) {
                final sel = f == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [if (sel) BoxShadow(color: AppColors.primaryGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    alignment: Alignment.center,
                    child: Text(f, style: TextStyle(color: sel ? Colors.white : AppColors.textPrimary, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: visible.length,
              itemBuilder: (_, i) => _seedCard(context, visible[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seedCard(BuildContext context, _Seed s) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomNetworkImage(
              url: s.imageUrl,
              borderRadius: 20,
              placeholderAsset: 'assets/images/placeholder.png',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(s.price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Redirecting to ${s.store}...')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Buy on ${s.store}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Seed {
  final String name, imageUrl, price, category, store;
  const _Seed(this.name, this.imageUrl, this.price, this.category, this.store);
}
