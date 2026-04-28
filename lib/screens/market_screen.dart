import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_network_image.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _sel = 'Rice';

  final Map<String, List<double>> _spots = {
    'Rice':      [2750, 2900, 2850, 3100, 3200, 3150, 3400],
    'Wheat':     [3000, 2950, 2900, 2880, 2820, 2790, 2800],
    'Cotton':    [6700, 6800, 6900, 7000, 7100, 7050, 7200],
    'Sugarcane': [305,  308,  310,  312,  315,  318,  320 ],
  };
  final Map<String, int>    _price  = {'Rice':3400,'Wheat':2800,'Cotton':7200,'Sugarcane':320};
  final Map<String, String> _change = {'Rice':'+15%','Wheat':'-5%','Cotton':'+8%','Sugarcane':'+3%'};
  final Map<String, bool>   _up     = {'Rice':true,'Wheat':false,'Cotton':true,'Sugarcane':true};
  final Map<String, String> _images = {
    'Rice': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&q=80&w=200',
    'Wheat': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&q=80&w=200',
    'Cotton': 'https://images.unsplash.com/photo-1594903582424-814643b97051?auto=format&fit=crop&q=80&w=200',
    'Sugarcane': 'https://images.unsplash.com/photo-1536679545597-c2e5e1946495?auto=format&fit=crop&q=80&w=200',
  };
  final List<String> _days = ['Apr 11','Apr 12','Apr 13','Apr 14','Apr 15','Apr 16','Apr 17'];

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    final spots = _spots[_sel]!;
    final minY  = spots.reduce((a,b)=>a<b?a:b) - 100;
    final maxY  = spots.reduce((a,b)=>a>b?a:b) + 100;
    final up    = _up[_sel]!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(lp.translate('market_prices'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Price card
          Container(
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomNetworkImage(
                      url: _images[_sel]!,
                      width: 50,
                      height: 50,
                      borderRadius: 12,
                      placeholderAsset: 'assets/images/placeholder.png',
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_sel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const Text('Quality: A1', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sel,
                          isDense: true,
                          items: _spots.keys.map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
                          onChanged: (v) => setState(() => _sel = v!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${_price[_sel]}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, left: 4),
                      child: Text('/ ${lp.translate('price_quintal')}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: up ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(up ? Icons.trending_up : Icons.trending_down, color: up ? Colors.green : Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text(_change[_sel]!, style: TextStyle(color: up ? Colors.green : Colors.red, fontWeight: FontWeight.w800, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: LineChart(LineChartData(
                    minY: minY, maxY: maxY,
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)))),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, _) {
                        final i = v.toInt(); if (i < 0 || i >= _days.length) return const SizedBox();
                        return Padding(padding: const EdgeInsets.only(top: 8), child: Text(_days[i], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)));
                      })),
                    ),
                    lineBarsData: [LineChartBarData(
                      spots: spots.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true, color: AppColors.primaryGreen, barWidth: 4, isStrokeCapRound: true,
                      dotData: FlDotData(show: true, getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(radius: 4, color: AppColors.primaryGreen, strokeWidth: 2, strokeColor: Colors.white)),
                      belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.primaryGreen.withOpacity(0.2), AppColors.primaryGreen.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                    )],
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Insight
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.insights, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(lp.translate('market_insight'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('$_sel ${up ? lp.translate('trending_up') : lp.translate('trending_down')}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text('${lp.translate('prediction')}: ${up ? "+12%" : "-3%"} next week', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // All Crop Prices
          Container(
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lp.translate('all_crop_prices'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                ..._price.entries.map((e) {
                  final isUp = _up[e.key]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        CustomNetworkImage(
                          url: _images[e.key]!,
                          width: 45,
                          height: 45,
                          borderRadius: 10,
                          placeholderAsset: 'assets/images/placeholder.png',
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const Text('Live Market', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${e.value}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                            Text(_change[e.key]!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isUp ? Colors.green : Colors.red)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
