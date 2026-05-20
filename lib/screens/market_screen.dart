import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/language_provider.dart';

class CropData {
  final String id;
  final String name;
  final String emoji;
  final String unit;
  final String cat;
  final double min;
  final double max;
  double modal;
  double change;
  final String action;
  final int conf;
  final int holdDays;
  final int stock;
  final double msp;

  CropData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.unit,
    required this.cat,
    required this.min,
    required this.max,
    required this.modal,
    required this.change,
    required this.action,
    required this.conf,
    required this.holdDays,
    required this.stock,
    required this.msp,
  });
}

class BuyerData {
  final String name;
  final String init;
  final Color color;
  final Color bg;
  final double rating;
  final String loc;
  final String dist;
  final List<String> crops;
  final bool verified;
  final int deals;
  final String price;
  final String type;

  BuyerData({
    required this.name,
    required this.init,
    required this.color,
    required this.bg,
    required this.rating,
    required this.loc,
    required this.dist,
    required this.crops,
    required this.verified,
    required this.deals,
    required this.price,
    required this.type,
  });
}

class AlertData {
  final String type; // success, danger, info, warning
  final String title;
  final String sub;
  final String time;
  bool read;

  AlertData({
    required this.type,
    required this.title,
    required this.sub,
    required this.time,
    required this.read,
  });
}

class AlertPref {
  final String label;
  final String sub;
  bool on;

  AlertPref({
    required this.label,
    required this.sub,
    required this.on,
  });
}

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  // Navigation & UI State
  String _activeTab = 'dashboard'; // dashboard, prices, trends, predict, holding, buyers, alerts
  String _selectedMandi = 'Koyambedu, Chennai';
  String _selectedCategory = 'all'; // all, cereal, vegetable, pulse, oilseed
  String _trendSubView = 'chart'; // chart, sentiment, seasonal
  List<String> _trendCropsSelected = ['rice', 'wheat'];
  String _selectedForecastCrop = 'Rice';
  String _buyerSearchQuery = '';
  String _buyerSort = 'rating';
  String _buyerSelectedCrop = 'All';
  String _alertCrop = 'Rice';
  String _alertDirection = 'Above';
  final TextEditingController _alertPriceController = TextEditingController();

  Timer? _timer;
  final Random _random = Random();

  // Mock Data
  late final List<CropData> _crops;
  late final List<BuyerData> _buyers;
  late final List<AlertData> _alerts;
  late final List<AlertPref> _alertPrefs;
  final List<Map<String, dynamic>> _customAlerts = [];

  final List<String> _mandis = ['Koyambedu, Chennai', 'Kancheepuram', 'Vellore', 'Salem', 'Coimbatore', 'Madurai'];
  final List<double> _mandiPrices = [2340, 2290, 2310, 2360, 2275, 2295];

  @override
  void initState() {
    super.initState();

    // Initialize mock crop datasets
    _crops = [
      CropData(id: 'rice', name: 'Rice (Ponni)', emoji: '🌾', unit: 'qtl', cat: 'cereal', min: 2180, max: 2420, modal: 2340, change: 4.2, action: 'sell', conf: 87, holdDays: 0, stock: 50, msp: 2183),
      CropData(id: 'tomato', name: 'Tomato', emoji: '🍅', unit: 'kg', cat: 'vegetable', min: 22, max: 35, modal: 28, change: -6.7, action: 'hold', conf: 72, holdDays: 7, stock: 200, msp: 0),
      CropData(id: 'onion', name: 'Onion', emoji: '🧅', unit: 'kg', cat: 'vegetable', min: 18, max: 26, modal: 22, change: 3.1, action: 'sell', conf: 80, holdDays: 0, stock: 150, msp: 0),
      CropData(id: 'wheat', name: 'Wheat', emoji: '🌿', unit: 'qtl', cat: 'cereal', min: 2050, max: 2200, modal: 2130, change: 1.4, action: 'sell', conf: 75, holdDays: 3, stock: 30, msp: 2275),
      CropData(id: 'potato', name: 'Potato', emoji: '🥔', unit: 'kg', cat: 'vegetable', min: 14, max: 19, modal: 16, change: -2.3, action: 'hold', conf: 65, holdDays: 10, stock: 300, msp: 0),
      CropData(id: 'chilli', name: 'Chilli (Dry)', emoji: '🌶', unit: 'kg', cat: 'vegetable', min: 68, max: 92, modal: 78, change: 8.9, action: 'sell', conf: 82, holdDays: 0, stock: 80, msp: 0),
      CropData(id: 'cotton', name: 'Cotton', emoji: '☁️', unit: 'qtl', cat: 'oilseed', min: 6200, max: 6800, modal: 6540, change: -1.1, action: 'hold', conf: 60, holdDays: 14, stock: 20, msp: 6620),
      CropData(id: 'groundnut', name: 'Groundnut', emoji: '🥜', unit: 'kg', cat: 'oilseed', min: 56, max: 68, modal: 62, change: 2.8, action: 'sell', conf: 70, holdDays: 0, stock: 100, msp: 0),
      CropData(id: 'maize', name: 'Maize', emoji: '🌽', unit: 'qtl', cat: 'cereal', min: 1750, max: 1920, modal: 1840, change: 0.9, action: 'hold', conf: 58, holdDays: 5, stock: 40, msp: 1870),
      CropData(id: 'urad', name: 'Urad Dal', emoji: '🫘', unit: 'kg', cat: 'pulse', min: 88, max: 108, modal: 96, change: 5.4, action: 'sell', conf: 78, holdDays: 0, stock: 60, msp: 0),
      CropData(id: 'turmeric', name: 'Turmeric', emoji: '🟡', unit: 'kg', cat: 'oilseed', min: 140, max: 175, modal: 158, change: 3.6, action: 'sell', conf: 74, holdDays: 0, stock: 30, msp: 0),
      CropData(id: 'soybean', name: 'Soybean', emoji: '🌱', unit: 'kg', cat: 'pulse', min: 41, max: 52, modal: 47, change: -1.9, action: 'hold', conf: 63, holdDays: 8, stock: 80, msp: 0),
    ];

    // Direct buyers configuration
    _buyers = [
      BuyerData(name: 'Ravi Traders', init: 'RT', color: const Color(0xFF14532D), bg: const Color(0xFFEAF2E3), rating: 4.8, loc: 'Koyambedu, Chennai', dist: '2 km', crops: ['Rice', 'Wheat', 'Pulses'], verified: true, deals: 142, price: '₹2,360', type: 'Wholesale Trader'),
      BuyerData(name: 'AgroFresh Co.', init: 'AF', color: const Color(0xFF0C447C), bg: const Color(0xFFEFF6FF), rating: 4.6, loc: 'Ambattur, Chennai', dist: '8 km', crops: ['Tomato', 'Onion', 'Potato'], verified: true, deals: 87, price: '₹30/kg', type: 'Processor'),
      BuyerData(name: 'Senthil Exports', init: 'SE', color: const Color(0xFF633806), bg: const Color(0xFFFEF3C7), rating: 4.5, loc: 'Tambaram, Chennai', dist: '18 km', crops: ['Rice', 'Cotton', 'Chilli'], verified: false, deals: 63, price: '₹2,350', type: 'Exporter'),
      BuyerData(name: 'Green Valley Pvt.', init: 'GV', color: const Color(0xFF14532D), bg: const Color(0xFFEAF2E3), rating: 4.9, loc: 'Poonamallee, Chennai', dist: '12 km', crops: ['Vegetables', 'Fruits', 'Spices'], verified: true, deals: 210, price: '₹32/kg', type: 'Supermarket Buyer'),
      BuyerData(name: 'Tamil Nadu FCI', init: 'TF', color: const Color(0xFF4A1B0C), bg: const Color(0xFFFEF2F2), rating: 4.7, loc: 'Guindy, Chennai', dist: '10 km', crops: ['Rice', 'Wheat', 'Maize'], verified: true, deals: 500, price: 'MSP rate', type: 'Government Procurement'),
      BuyerData(name: 'Murugan Millers', init: 'MM', color: const Color(0xFF1F4E79), bg: const Color(0xFFEFF6FF), rating: 4.3, loc: 'Sriperumbudur', dist: '35 km', crops: ['Rice', 'Wheat', 'Groundnut'], verified: true, deals: 98, price: '₹2,320', type: 'Rice Mill'),
      BuyerData(name: 'Spice Route Co.', init: 'SR', color: const Color(0xFF633806), bg: const Color(0xFFFEF3C7), rating: 4.6, loc: 'Perungudi, Chennai', dist: '14 km', crops: ['Chilli', 'Turmeric', 'Onion'], verified: true, deals: 75, price: '₹82/kg', type: 'Export House'),
    ];

    // Notification alerts
    _alerts = [
      AlertData(type: 'success', title: 'Rice prices up 4.2% — ideal time to sell', sub: 'Koyambedu mandi · Modal: ₹2,340/qtl', time: 'Just now', read: false),
      AlertData(type: 'danger', title: 'Tomato glut: prices fell 6.7% today', sub: 'Excess arrivals expected for 3–5 more days. Hold stock.', time: '1h ago', read: false),
      AlertData(type: 'info', title: 'New buyer near you: Green Valley Pvt.', sub: 'Buying tomatoes at ₹32/kg · Rating: 4.9 ★ · 2 km away', time: '3h ago', read: false),
      AlertData(type: 'warning', title: 'Weather alert: heavy rain forecast in Salem belt', sub: 'May affect tomato & onion supply chain this week', time: '4h ago', read: true),
      AlertData(type: 'success', title: 'MSP for wheat raised to ₹2,275/qtl', sub: 'Government of India official announcement for Kharif 2026', time: 'Yesterday', read: true),
      AlertData(type: 'success', title: 'Best sell window: Onion — Tomorrow & Friday', sub: 'AI prediction · Expected price: ₹24–26/kg · 80% confidence', time: 'Yesterday', read: true),
      AlertData(type: 'info', title: 'Export demand surge: Chilli prices rising', sub: 'Middle East buyers increasing import volumes. Price up 8.9%', time: '2 days ago', read: true),
      AlertData(type: 'warning', title: 'Urad Dal: MSP procurement opens next week', sub: 'Register at nearest NAFED centre before 25 May', time: '2 days ago', read: true),
    ];

    // Alert Preferences
    _alertPrefs = [
      AlertPref(label: 'Price spike alerts', sub: 'Notify when crop prices rise >3%', on: true),
      AlertPref(label: 'Sell window notifications', sub: 'AI-predicted best selling days', on: true),
      AlertPref(label: 'New buyer in your area', sub: 'Alert when verified buyer is near', on: true),
      AlertPref(label: 'Price drop warnings', sub: 'Notify when prices fall sharply', on: true),
      AlertPref(label: 'Weather impact warnings', sub: 'Rain, drought & supply disruptions', on: false),
      AlertPref(label: 'Government MSP updates', sub: 'Official minimum support price changes', on: true),
      AlertPref(label: 'Weekly market summary', sub: 'Sunday morning digest', on: false),
    ];

    // Periodic Timer simulating live data fluctuations
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          for (var c in _crops) {
            double deviation = (_random.nextDouble() - 0.5) * 0.2;
            c.modal = (c.modal * (1 + deviation / 100)).roundToDouble();
            c.change = double.parse((c.change + (_random.nextDouble() - 0.5) * 0.1).toStringAsFixed(1));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _alertPriceController.dispose();
    super.dispose();
  }

  // Visual helper method to style indicators
  String _fmt(double n) {
    return n >= 1000 ? '₹${n.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}' : '₹${n.toInt()}';
  }

  String _getSellReason(String cropId) {
    final Map<String, String> reasons = {
      'rice': 'Prices at 8-week high. Expected dip after harvest season. Best to sell within 3 days.',
      'onion': 'Export demand strong from Middle East buyers. Price surge of 12% vs last month.',
      'chilli': 'Domestic demand peak. Festive season orders driving prices up. Act before new crop arrives.',
      'wheat': 'Post-rabi season demand from flour mills is high. Sell before government releases buffer stock.',
      'groundnut': 'Oil mill procurement active. Prices above MSP — good window to sell.',
      'urad': 'Pulse import restrictions tightened. Domestic prices rising steadily.',
      'turmeric': 'Export enquiries surge. Price expected to rise further in June.',
    };
    return reasons[cropId] ?? 'Market conditions favorable. Consider selling now for good returns.';
  }

  Widget _buildCard({required Widget child, Color? color, EdgeInsets? padding, double? borderRadius}) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.cardWhite,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Row(
          children: [
            const Text('🌾', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KisanMandi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(lp.translate('Smart Market Intelligence'), style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.8), letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text('Live Prices', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Colors.white),
                if (_alerts.any((a) => !a.read))
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.alertRed, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            onPressed: () => setState(() => _activeTab = 'alerts'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Price Ticker
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.06),
              border: Border(bottom: BorderSide(color: AppColors.primaryGreen.withOpacity(0.1), width: 1)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _crops.length * 3, // Repeat to make infinite scrolling effect
              itemBuilder: (context, index) {
                final crop = _crops[index % _crops.length];
                final isUp = crop.change >= 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: AppColors.primaryGreen.withOpacity(0.1), width: 1)),
                  ),
                  child: Row(
                    children: [
                      Text(crop.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(crop.name.split(' ')[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(width: 4),
                      Text(_fmt(crop.modal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textGreen)),
                      const SizedBox(width: 4),
                      Text(
                        '${isUp ? '▲' : '▼'} ${crop.change.abs()}%',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isUp ? Colors.green : AppColors.alertRed),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Horizontal scrolling tabs navigation
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildTabButton('dashboard', Icons.dashboard, 'Dashboard'),
                _buildTabButton('prices', Icons.trending_up, 'Live Prices'),
                _buildTabButton('trends', Icons.analytics, 'Trends'),
                _buildTabButton('predict', Icons.query_builder, 'Best Time to Sell'),
                _buildTabButton('holding', Icons.inventory_2, 'Stock Holding'),
                _buildTabButton('buyers', Icons.people, 'Buyers'),
                _buildTabButton('alerts', Icons.notifications, 'Alerts'),
              ],
            ),
          ),
          // Scrollable Body containing specific Tab Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_activeTab == 'dashboard') _buildDashboardTab(lp),
                if (_activeTab == 'prices') _buildPricesTab(lp),
                if (_activeTab == 'trends') _buildTrendsTab(lp),
                if (_activeTab == 'predict') _buildPredictTab(lp),
                if (_activeTab == 'holding') _buildHoldingTab(lp),
                if (_activeTab == 'buyers') _buildBuyersTab(lp),
                if (_activeTab == 'alerts') _buildAlertsTab(lp),
                const SizedBox(height: 80), // extra scrolling pad
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, IconData icon, String label) {
    final isSelected = _activeTab == tabId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _activeTab = tabId),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TAB 1: DASHBOARD ====================
  Widget _buildDashboardTab(LanguageProvider lp) {
    final topOpp = _crops.firstWhere((c) => c.id == 'rice');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Header
        const Text('Good morning, Farmer! 🌤️', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        const Text('Wednesday, 20 May 2026 · Koyambedu Mandi rates updated 9 min ago', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 16),

        // Hero Top Opportunity
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔥 ', style: TextStyle(fontSize: 12)),
                          Text('Top opportunity today', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(topOpp.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('Koyambedu Mandi · Chennai, TN', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFF4ADE80).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: const Text('✓ Sell Now', style: TextStyle(fontSize: 11, color: Color(0xFF4ADE80), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text('Confidence: ${topOpp.conf}%', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_fmt(topOpp.modal), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF4ADE80))),
                  Text('per ${topOpp.unit}', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text('▲ +${topOpp.change}% today', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Quick metric cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMetricTile('🌾', 'Rice', _crops.firstWhere((c) => c.id == 'rice')),
            _buildMetricTile('🍅', 'Tomato', _crops.firstWhere((c) => c.id == 'tomato')),
            _buildMetricTile('🧅', 'Onion', _crops.firstWhere((c) => c.id == 'onion')),
            _buildMetricTileCustom('👥', 'Active Buyers', '18', 'Near you', const Color(0xFF3B82F6)),
          ],
        ),
        const SizedBox(height: 16),

        // Row of split cards
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('AI Selling Recommendations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  Text('Updated 9 min ago', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              ..._crops.where((c) => c.action == 'sell').take(3).map((crop) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        child: Text(crop.emoji, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(crop.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                  child: const Text('✓ Sell Now', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(_getSellReason(crop.id), style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.gps_fixed, size: 10, color: Colors.grey.shade500),
                                const SizedBox(width: 3),
                                Text('🎯 Target: ${_fmt(crop.modal * 1.02)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                const SizedBox(width: 12),
                                Icon(Icons.verified_user_outlined, size: 10, color: Colors.grey.shade500),
                                const SizedBox(width: 3),
                                Text('Confidence: ${crop.conf}%', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // 7-day rice trend chart
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('7-Day Rice Price Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  Text('₹ per quintal', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Today'];
                            int idx = v.toInt();
                            if (idx >= 0 && idx < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(days[idx], style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 2180),
                          FlSpot(1, 2195),
                          FlSpot(2, 2220),
                          FlSpot(3, 2260),
                          FlSpot(4, 2245),
                          FlSpot(5, 2295),
                          FlSpot(6, 2340),
                        ],
                        isCurved: true,
                        color: AppColors.primaryGreen,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(radius: 3, color: AppColors.primaryGreen, strokeWidth: 1.5, strokeColor: Colors.white),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [AppColors.primaryGreen.withOpacity(0.15), AppColors.primaryGreen.withOpacity(0.0)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Market comparison progress list
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Market Comparison', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  Text('Rice ₹/qtl', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(_mandis.length, (index) {
                final m = _mandis[index];
                final price = _mandiPrices[index];
                final maxPrice = _mandiPrices.reduce(max);
                final ratio = price / maxPrice;
                final isTop = price == maxPrice;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(_fmt(price), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isTop ? AppColors.textGreen : AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(isTop ? AppColors.primaryGreen : Colors.green.shade700),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Overall price table
        _buildCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text("Today's Price Summary — All Crops", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  horizontalMargin: 8,
                  headingRowHeight: 34,
                  dataRowMaxHeight: 52,
                  columns: const [
                    DataColumn(label: Text('Crop', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Min', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Max', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Modal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Rec', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                  rows: _crops.map((crop) {
                    final isUp = crop.change >= 0;
                    return DataRow(
                      cells: [
                        DataCell(Row(
                          children: [
                            Text(crop.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(crop.name.split(' ')[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        )),
                        DataCell(Text(_fmt(crop.min), style: TextStyle(fontSize: 11, color: Colors.grey.shade500))),
                        DataCell(Text(_fmt(crop.max), style: TextStyle(fontSize: 11, color: Colors.grey.shade500))),
                        DataCell(Text('${_fmt(crop.modal)}/${crop.unit}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataCell(Text(
                          '${isUp ? '▲' : '▼'} ${crop.change.abs()}%',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUp ? Colors.green : AppColors.alertRed),
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: crop.action == 'sell' ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            crop.action == 'sell' ? '✓ Sell' : '⏳ Hold',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: crop.action == 'sell' ? Colors.green : Colors.amber.shade800),
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String emoji, String title, CropData crop) {
    final isUp = crop.change >= 0;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Text(_fmt(crop.modal), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(isUp ? Icons.trending_up : Icons.trending_down, size: 12, color: isUp ? Colors.green : AppColors.alertRed),
              const SizedBox(width: 3),
              Text(
                '${isUp ? '+' : ''}${crop.change}%',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUp ? Colors.green : AppColors.alertRed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTileCustom(String emoji, String title, String val, String subtitle, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accentColor)),
        ],
      ),
    );
  }

  // ==================== TAB 2: LIVE PRICES ====================
  Widget _buildPricesTab(LanguageProvider lp) {
    final filtered = _selectedCategory == 'all' ? _crops : _crops.where((c) => c.cat == _selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Live Crop Prices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const Text('Real-time rates from major Tamil Nadu mandis', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 12),

        // Dropdown & Category Selector Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMandi,
                  isDense: true,
                  items: _mandis.map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))).toList(),
                  onChanged: (v) => setState(() => _selectedMandi = v!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryChip('all', 'All'),
              _buildCategoryChip('cereal', 'Cereals'),
              _buildCategoryChip('vegetable', 'Vegetables'),
              _buildCategoryChip('pulse', 'Pulses'),
              _buildCategoryChip('oilseed', 'Oilseeds'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Live Prices List Table
        _buildCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price Table', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('Live · ${_selectedMandi.split(',')[0]}', style: TextStyle(fontSize: 11, color: AppColors.textGreen, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 14,
                  horizontalMargin: 8,
                  headingRowHeight: 34,
                  dataRowMaxHeight: 52,
                  columns: const [
                    DataColumn(label: Text('Crop', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Min', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Max', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Modal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('MSP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Rec', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((c) {
                    // simulate adjustments based on selected mandi index to make prices fluctuate realistically
                    int idx = _mandis.indexOf(_selectedMandi);
                    double offset = (idx * 5 - 10).toDouble();
                    double adjustedModal = c.modal + offset;
                    bool isUp = c.change >= 0;

                    Widget mspBadge = c.msp > 0
                        ? (adjustedModal >= c.msp
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: const Text('Above MSP', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.w800)))
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: const Text('Below MSP', style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.w800))))
                        : const Text('—', style: TextStyle(fontSize: 11, color: AppColors.textSecondary));

                    return DataRow(
                      cells: [
                        DataCell(Row(
                          children: [
                            Text(c.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.name.split(' ')[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text(c.cat, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                              ],
                            ),
                          ],
                        )),
                        DataCell(Text(_fmt(c.min), style: TextStyle(fontSize: 11, color: Colors.grey.shade500))),
                        DataCell(Text(_fmt(c.max), style: TextStyle(fontSize: 11, color: Colors.grey.shade500))),
                        DataCell(Text('${_fmt(adjustedModal)}/${c.unit}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataCell(mspBadge),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: c.action == 'sell' ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            c.action == 'sell' ? 'Sell' : 'Hold',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c.action == 'sell' ? Colors.green : Colors.amber.shade800),
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Grouped chart and best market
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Price Range Distribution', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 2500,
                    gridData: FlGridData(show: true, drawHorizontalLine: true, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 34,
                          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            int idx = v.toInt();
                            if (idx >= 0 && idx < filtered.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('${filtered[idx].emoji} ${filtered[idx].name.split(' ')[0]}', style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(min(5, filtered.length), (index) {
                      final c = filtered[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(toY: c.min, color: Colors.red.shade300, width: 6),
                          BarChartRodData(toY: c.modal, color: AppColors.primaryGreen, width: 6),
                          BarChartRodData(toY: c.max, color: Colors.blue.shade300, width: 6),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Best Market details
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('⭐ ', style: TextStyle(fontSize: 14)),
                  Text('Best Market for Rice Today', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(_mandis.length, (index) {
                final m = _mandis[index];
                final price = _mandiPrices[index];
                final maxPrice = _mandiPrices.reduce(max);
                final ratio = price / maxPrice;
                final isTop = price == maxPrice;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(m, style: TextStyle(fontSize: 12, fontWeight: isTop ? FontWeight.bold : FontWeight.normal))),
                      Expanded(
                        flex: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(isTop ? AppColors.primaryGreen : Colors.green.shade700),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_fmt(price), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isTop ? Colors.green : Colors.grey.shade700)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String catId, String label) {
    final isSelected = _selectedCategory == catId;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        onSelected: (v) => setState(() => _selectedCategory = catId),
        selectedColor: AppColors.primaryGreen.withOpacity(0.12),
        labelStyle: TextStyle(color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary),
        backgroundColor: Colors.white,
      ),
    );
  }

  // ==================== TAB 3: MARKET TRENDS ====================
  Widget _buildTrendsTab(LanguageProvider lp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Market Trend Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const Text('30-day price movement & sentiment analysis', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 12),

        // Subtabs
        Row(
          children: [
            _buildSubTabViewChip('chart', 'Price Chart'),
            _buildSubTabViewChip('sentiment', 'Sentiment'),
            _buildSubTabViewChip('seasonal', 'Seasonal'),
          ],
        ),
        const SizedBox(height: 16),

        if (_trendSubView == 'chart') ...[
          // Crop selection chips
          Wrap(
            spacing: 6,
            children: _crops.take(6).map((c) {
              final isSelected = _trendCropsSelected.contains(c.id);
              return FilterChip(
                label: Text('${c.emoji} ${c.name.split(' ')[0]}', style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen.withOpacity(0.15),
                checkmarkColor: AppColors.primaryGreen,
                onSelected: (v) {
                  setState(() {
                    if (isSelected) {
                      _trendCropsSelected.remove(c.id);
                    } else {
                      _trendCropsSelected.add(c.id);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // 30-Day Trend Chart
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('30-Day Price Trend', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('Select crops above', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              if (v == 0) return const Text('30d ago', style: TextStyle(fontSize: 8));
                              if (v == 14) return const Text('15d ago', style: TextStyle(fontSize: 8));
                              if (v == 29) return const Text('Today', style: TextStyle(fontSize: 8));
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: _trendCropsSelected.map((cropId) {
                        final c = _crops.firstWhere((x) => x.id == cropId, orElse: () => _crops[0]);
                        // generate dynamic data coordinates
                        List<FlSpot> spots = [];
                        for (int i = 0; i < 30; i++) {
                          double val = c.modal * (0.92 + (i * 0.003) + sin(i * 0.4) * 0.03);
                          spots.add(FlSpot(i.toDouble(), val));
                        }
                        return LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: cropId == 'rice'
                              ? Colors.green
                              : cropId == 'wheat'
                                  ? Colors.blue
                                  : cropId == 'tomato'
                                      ? Colors.red
                                      : Colors.amber,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Volume analysis bar chart
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Volume Analysis (Arrivals in tons)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: BarChart(
                    BarChartData(
                      maxY: 2000,
                      gridData: FlGridData(show: true, drawHorizontalLine: true, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}t', style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Today'];
                              int idx = v.toInt();
                              if (idx >= 0 && idx < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(days[idx], style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1200, color: AppColors.primaryGreen.withOpacity(0.65), width: 14)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 980, color: AppColors.primaryGreen.withOpacity(0.65), width: 14)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1350, color: AppColors.primaryGreen.withOpacity(0.65), width: 14)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 1100, color: AppColors.primaryGreen.withOpacity(0.65), width: 14)]),
                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 1420, color: AppColors.primaryGreen.withOpacity(0.65), width: 14)]),
                        BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 890, color: AppColors.primaryGreen.withOpacity(0.65), width: 14)]),
                        BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 1560, color: AppColors.primaryGreen.withOpacity(0.65), width: 14)]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Price Volatility Index
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price Volatility Index', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._crops.take(6).map((c) {
                  double volatility = c.change.abs() + 2.5;
                  String level = volatility > 8 ? 'High' : volatility > 4 ? 'Medium' : 'Low';
                  Color col = volatility > 8 ? Colors.red : volatility > 4 ? Colors.amber : Colors.green;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('${c.emoji} ${c.name.split(' ')[0]}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(value: volatility / 12, backgroundColor: Colors.grey.shade100, valueColor: AlwaysStoppedAnimation<Color>(col), minHeight: 6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$level (${volatility.toStringAsFixed(1)}%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],

        if (_trendSubView == 'sentiment') ...[
          // Sentiment cards
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Market Sentiment — This Week', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildSentimentBar('🌾 Rice', 82, 'Bullish', Colors.green),
                _buildSentimentBar('🧅 Onion', 74, 'Bullish', Colors.green),
                _buildSentimentBar('🌶 Chilli', 88, 'Very Bullish', Colors.green.shade800),
                _buildSentimentBar('🍅 Tomato', 32, 'Bearish', Colors.red),
                _buildSentimentBar('☁️ Cotton', 44, 'Slightly Bearish', Colors.amber),
                _buildSentimentBar('🥔 Potato', 40, 'Bearish', Colors.red),
              ],
            ),
          ),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sentiment Factors', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildSentimentBar('Weather conditions', 72, '72%', Colors.green),
                _buildSentimentBar('Export demand', 85, '85%', Colors.green),
                _buildSentimentBar('Mandi arrivals (supply)', 38, '38%', Colors.red),
                _buildSentimentBar('Government procurement', 65, '65%', Colors.blue),
                _buildSentimentBar('Fuel/transport costs', 50, '50%', Colors.amber),
              ],
            ),
          ),
        ],

        if (_trendSubView == 'seasonal') ...[
          // Seasonal Pattern line chart for Rice (yearly average)
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seasonal Price Pattern — Rice (Yearly Average)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final List<String> mths = ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];
                              int idx = v.toInt();
                              if (idx % 2 == 0 && idx >= 0 && idx < 12) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(mths[idx ~/ 2], style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 2050),
                            FlSpot(1, 2080),
                            FlSpot(2, 2120),
                            FlSpot(3, 2150),
                            FlSpot(4, 2200),
                            FlSpot(5, 2340),
                            FlSpot(6, 2380),
                            FlSpot(7, 2250),
                            FlSpot(8, 2100),
                            FlSpot(9, 2080),
                            FlSpot(10, 2060),
                            FlSpot(11, 2030),
                          ],
                          isCurved: true,
                          color: AppColors.primaryGreen,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, p1, p2, p3) => FlDotCirclePainter(
                              radius: spot.y >= 2300 ? 4 : 2,
                              color: spot.y >= 2300 ? Colors.amber : AppColors.primaryGreen,
                              strokeColor: Colors.white,
                              strokeWidth: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Peak Selling Months', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildSeasonalBreakdownRow('🟡 Peak months', 'Jun – Aug', 'Demand peaks post-harvest. Best time to sell stored rice.', Colors.amber),
                _buildSeasonalBreakdownRow('🔴 Low months', 'Oct – Jan', 'New crop arrivals suppress prices. Avoid selling large volumes.', Colors.red),
                _buildSeasonalBreakdownRow('🟢 Stable months', 'Feb – May', 'Gradual price recovery. Good for partial selling strategy.', Colors.green),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubTabViewChip(String viewId, String label) {
    final isSelected = _trendSubView == viewId;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () => setState(() => _trendSubView = viewId),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryGreen.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSentimentBar(String label, double score, String ratingText, Color col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(ratingText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(col),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalBreakdownRow(String title, String monthRange, String desc, Color col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(monthRange, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col)),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4)),
        ],
      ),
    );
  }

  // ==================== TAB 4: BEST TIME TO SELL ====================
  Widget _buildPredictTab(LanguageProvider lp) {
    final selectedCropData = _crops.firstWhere(
      (c) => c.name.toLowerCase().contains(_selectedForecastCrop.toLowerCase()),
      orElse: () => _crops[0],
    );

    // Dynamic predicted values
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<double> scores = [62, 70, 68, 88, 85, 55, 48];
    final double maxScore = scores.reduce(max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Best Time to Sell', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const Text('AI-powered price prediction & optimal selling windows', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 12),

        // Crop selector
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedForecastCrop,
                  isDense: true,
                  items: ['Rice', 'Tomato', 'Onion', 'Wheat', 'Potato', 'Chilli']
                      .map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedForecastCrop = v!),
                ),
              ),
            ),
            const Spacer(),
            Text('Confidence: ${selectedCropData.conf}%', style: TextStyle(fontSize: 11, color: AppColors.textGreen, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 14),

        // Vertical Bars representing optimal sell days
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Best Selling Days — Next 7 Days', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(days.length, (index) {
                  final score = scores[index];
                  final isBest = score >= 80;
                  final height = (score / maxScore * 100) + 12;
                  final dayPrice = selectedCropData.modal * (0.95 + score / maxScore * 0.08);

                  return Column(
                    children: [
                      Container(
                        height: height,
                        width: 28,
                        decoration: BoxDecoration(
                          color: isBest ? const Color(0xFF4ADE80).withOpacity(0.2) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isBest ? const Color(0xFF4ADE80) : Colors.grey.shade300),
                        ),
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          _fmt(dayPrice).replaceAll('₹', ''),
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isBest ? Colors.green.shade800 : Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(days[index], style: TextStyle(fontSize: 9, fontWeight: isBest ? FontWeight.bold : FontWeight.normal, color: isBest ? Colors.green.shade800 : Colors.grey.shade600)),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF4ADE80).withOpacity(0.2), border: Border.all(color: const Color(0xFF4ADE80)), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Text('🟢 Recommended selling days (highest prices)', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        ),

        // 14-Day Price Forecast
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('14-Day Price Forecast', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 34,
                          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            int idx = v.toInt();
                            if (idx % 3 == 0) return Text('D+${idx + 1}', style: const TextStyle(fontSize: 8));
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Forecast line
                      LineChartBarData(
                        spots: List.generate(14, (i) {
                          double val = selectedCropData.modal * (0.97 + sin(i * 0.5) * 0.04 + i * 0.003);
                          return FlSpot(i.toDouble(), val);
                        }),
                        isCurved: true,
                        color: AppColors.primaryGreen,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                      // Upper bound dashed
                      LineChartBarData(
                        spots: List.generate(14, (i) {
                          double val = selectedCropData.modal * (0.97 + sin(i * 0.5) * 0.04 + i * 0.003) * 1.03;
                          return FlSpot(i.toDouble(), val);
                        }),
                        isCurved: true,
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        barWidth: 1,
                        dashArray: [4, 4],
                        dotData: const FlDotData(show: false),
                      ),
                      // Lower bound dashed
                      LineChartBarData(
                        spots: List.generate(14, (i) {
                          double val = selectedCropData.modal * (0.97 + sin(i * 0.5) * 0.04 + i * 0.003) * 0.97;
                          return FlSpot(i.toDouble(), val);
                        }),
                        isCurved: true,
                        color: Colors.red.withOpacity(0.3),
                        barWidth: 1,
                        dashArray: [4, 4],
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Confidence factors
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Prediction Confidence Factors', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildSentimentBar('Historical price patterns', 90, '90%', Colors.green),
              _buildSentimentBar('Weather forecast data', 78, '78%', Colors.green),
              _buildSentimentBar('Market arrival volumes', 65, '65%', Colors.blue),
              _buildSentimentBar('Export/import trends', 82, '82%', Colors.green),
              _buildSentimentBar('Government policy signals', 70, '70%', Colors.amber),
            ],
          ),
        ),

        // Accuracy History
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Historical Accuracy (Forecast vs Actual)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 34,
                          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final List<String> wks = ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4', 'Wk 5', 'Wk 6'];
                            int idx = v.toInt();
                            if (idx >= 0 && idx < wks.length) {
                              return Padding(padding: const EdgeInsets.only(top: 8), child: Text(wks[idx], style: const TextStyle(fontSize: 8)));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [FlSpot(0, 2280), FlSpot(1, 2310), FlSpot(2, 2260), FlSpot(3, 2290), FlSpot(4, 2320), FlSpot(5, 2340)],
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        dashArray: [3, 3],
                      ),
                      LineChartBarData(
                        spots: const [FlSpot(0, 2295), FlSpot(1, 2305), FlSpot(2, 2270), FlSpot(3, 2285), FlSpot(4, 2315), FlSpot(5, 2340)],
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 8, height: 2, color: Colors.blue),
                  const SizedBox(width: 4),
                  const Text('Predicted', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 16),
                  Container(width: 8, height: 2, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text('Actual', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== TAB 5: STOCK HOLDING ====================
  Widget _buildHoldingTab(LanguageProvider lp) {
    final holdingCrops = _crops.where((c) => c.stock > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stock Holding Recommendation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const Text('Decide how long to hold your stock for maximum profit', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 12),

        // Stock inventory list
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Stock Inventory', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...holdingCrops.map((c) {
                double gainPct = c.action == 'sell' ? c.change : (c.holdDays * 0.8);
                double expectedGain = c.modal * c.stock * (gainPct / 100);

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1))),
                  child: Row(
                    children: [
                      Text(c.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            Text('Stock: ${c.stock} ${c.unit} · Current value: ${_fmt(c.modal * c.stock)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${gainPct >= 0 ? '+' : ''}${gainPct.toStringAsFixed(1)}% est.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gainPct >= 0 ? Colors.green : Colors.red)),
                          Text('Gain: +${_fmt(expectedGain > 0 ? expectedGain : 0)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.action == 'sell' ? Colors.green.withOpacity(0.15) : Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.action == 'sell' ? 'Sell Now' : 'Hold ${c.holdDays}d',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: c.action == 'sell' ? Colors.green : Colors.amber.shade800),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Expected Profit Hold Chart
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Expected Profit if You Hold', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: true, drawHorizontalLine: true, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          getTitlesWidget: (v, _) => Text(_fmt(v), style: TextStyle(fontSize: 7, color: Colors.grey.shade500)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final List<String> horizons = ['Now', '3 days', '1 week', '2 weeks', '1 month'];
                            int idx = v.toInt();
                            if (idx >= 0 && idx < horizons.length) {
                              return Padding(padding: const EdgeInsets.only(top: 8), child: Text(horizons[idx], style: const TextStyle(fontSize: 8)));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: Colors.green, width: 8), BarChartRodData(toY: 0, color: Colors.blue, width: 8)]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1200, color: Colors.green, width: 8), BarChartRodData(toY: 200, color: Colors.blue, width: 8)]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2800, color: Colors.green, width: 8), BarChartRodData(toY: 2400, color: Colors.blue, width: 8)]),
                      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 1800, color: Colors.green, width: 8), BarChartRodData(toY: 3800, color: Colors.blue, width: 8)]),
                      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 500, color: Colors.green, width: 8), BarChartRodData(toY: 1200, color: Colors.blue, width: 8)]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Storage cost analysis details
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Storage Cost vs Price Gain', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildSeasonalBreakdownRow('Daily storage cost (Rice)', '₹2.50/qtl/day', 'Cold storage: ₹3.50/qtl/day · Warehouse: ₹1.50/qtl/day', Colors.red),
              _buildSeasonalBreakdownRow('Break-even hold days', '4 days', 'After 4 days, storage cost exceeds expected price gain for rice', Colors.amber),
              _buildSeasonalBreakdownRow('Optimal hold (Tomato)', '5–7 days', 'Weekend demand expected to push prices from ₹28 to ₹38–42/kg', Colors.green),
            ],
          ),
        ),

        // Risk cards list
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text('Risk Assessment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            _buildRiskCard('🌾 Rice', 'Risk: Low', 'Stable demand, good storage life, MSP safety net', Colors.green),
            _buildRiskCard('🍅 Tomato', 'Risk: High', 'Perishable, price volatile, hold max 5–7 days only', Colors.red),
            _buildRiskCard('🧅 Onion', 'Risk: Medium', 'Good shelf life but price can swing on export policy', Colors.amber),
            _buildRiskCard('☁️ Cotton', 'Risk: Medium', 'International price dependency, currency risk', Colors.amber),
          ],
        ),
      ],
    );
  }

  Widget _buildRiskCard(String crop, String riskText, String desc, Color col) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(crop, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(riskText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: col)),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4)),
        ],
      ),
    );
  }

  // ==================== TAB 6: DIRECT BUYERS ====================
  Widget _buildBuyersTab(LanguageProvider lp) {
    // Apply filters
    final filtered = _buyers.where((b) {
      final matchesSearch = b.name.toLowerCase().contains(_buyerSearchQuery.toLowerCase()) ||
          b.loc.toLowerCase().contains(_buyerSearchQuery.toLowerCase()) ||
          b.crops.any((c) => c.toLowerCase().contains(_buyerSearchQuery.toLowerCase()));

      final matchesCrop = _buyerSelectedCrop == 'All' || b.crops.any((c) => c.toLowerCase().contains(_buyerSelectedCrop.toLowerCase()));

      return matchesSearch && matchesCrop;
    }).toList();

    // Sorting logic
    if (_buyerSort == 'rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_buyerSort == 'deals') {
      filtered.sort((a, b) => b.deals.compareTo(a.deals));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Direct Buyer Connection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const Text('Connect directly with verified traders, exporters & processors', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 12),

        // Interactive search box
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            onChanged: (v) => setState(() => _buyerSearchQuery = v),
            decoration: const InputDecoration(
              icon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              hintText: 'Search buyers by name, crop, or location...',
              hintStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Crop Tag horizontal scroll filters
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'Rice', 'Tomato', 'Onion', 'Wheat', 'Cotton', 'Vegetables', 'Spices'].map((cropFilter) {
              final isSelected = _buyerSelectedCrop == cropFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(cropFilter, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected,
                  onSelected: (v) => setState(() => _buyerSelectedCrop = cropFilter),
                  selectedColor: AppColors.primaryGreen.withOpacity(0.12),
                  labelStyle: TextStyle(color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary),
                  backgroundColor: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Sort option dropdown row
        Row(
          children: [
            Text('Sort by: ', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _buyerSort,
                  isDense: true,
                  items: const [
                    DropdownMenuItem(value: 'rating', child: Text('Rating ★', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'deals', child: Text('Deals done', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                  onChanged: (v) => setState(() => _buyerSort = v!),
                ),
              ),
            ),
            const Spacer(),
            Text('${filtered.length} buyers found', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 12),

        // Buyers cards list
        ...filtered.map((buyer) {
          return _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: buyer.bg,
                      child: Text(buyer.init, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: buyer.color)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(buyer.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              if (buyer.verified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, size: 14, color: Colors.blue),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('📍 ${buyer.loc} · ${buyer.dist}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              ...List.generate(5, (starIdx) {
                                final active = starIdx < buyer.rating.floor();
                                return Icon(active ? Icons.star : Icons.star_border, size: 12, color: Colors.amber);
                              }),
                              const SizedBox(width: 4),
                              Text('${buyer.rating} · ${buyer.deals} deals', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action contact btn
                    ElevatedButton.icon(
                      onPressed: () => _showBuyerContactSheet(buyer),
                      icon: const Icon(Icons.phone, size: 12),
                      label: const Text('Contact', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade800,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Crops tags list
                    Wrap(
                      spacing: 4,
                      children: buyer.crops.map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                          child: Text(c, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                        );
                      }).toList(),
                    ),
                    Text(
                      '${buyer.type} · Offers: ${buyer.price}',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen.withOpacity(0.95)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showBuyerContactSheet(BuyerData buyer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 24, backgroundColor: buyer.bg, child: Text(buyer.init, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: buyer.color))),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(buyer.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${buyer.type} · ${buyer.loc}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Connecting Options', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.message, color: Colors.green),
                ),
                title: const Text('Chat on WhatsApp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Send a dynamic WhatsApp template instantly', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connecting to ${buyer.name} on WhatsApp...')));
                },
              ),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.phone, color: Colors.blue),
                ),
                title: const Text('Call direct line', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Connect directly to trader phone number', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dialing ${buyer.name} contact number...')));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== TAB 7: ALERTS ====================
  Widget _buildAlertsTab(LanguageProvider lp) {
    final unreadCount = _alerts.where((a) => !a.read).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alerts & Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const Text('Stay updated with real-time market signals', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 12),

        // Preferences card with toggles
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alert Preferences', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._alertPrefs.map((pref) {
                return SwitchListTile(
                  title: Text(pref.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  subtitle: Text(pref.sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  value: pref.on,
                  activeColor: AppColors.primaryGreen,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => pref.on = v),
                );
              }),
            ],
          ),
        ),

        // Recent Notifications Feed List
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('$unreadCount unread', style: TextStyle(fontSize: 11, color: AppColors.textGreen, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ..._alerts.map((a) {
                Color indicatorCol = Colors.green;
                if (a.type == 'danger') indicatorCol = Colors.red;
                if (a.type == 'warning') indicatorCol = Colors.amber;
                if (a.type == 'info') indicatorCol = Colors.blue;

                return InkWell(
                  onTap: () {
                    setState(() => a.read = true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4, right: 10),
                          decoration: BoxDecoration(
                            color: indicatorCol,
                            shape: BoxShape.circle,
                            boxShadow: a.read ? null : [BoxShadow(color: indicatorCol.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title, style: TextStyle(fontSize: 12, fontWeight: a.read ? FontWeight.normal : FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(a.sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        Text(a.time, style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Price Alert Setup
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Price Alert Setup', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              // Crop Dropdown
              const Text('Crop', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _alertCrop,
                    isExpanded: true,
                    items: ['Rice', 'Tomato', 'Onion', 'Wheat'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (v) => setState(() => _alertCrop = v!),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Alert Direction Dropdown
              const Text('Notify when price goes', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _alertDirection,
                    isExpanded: true,
                    items: ['Above', 'Below'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (v) => setState(() => _alertDirection = v!),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Target price input
              const Text('Target Price (₹)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _alertPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 2500',
                    hintStyle: TextStyle(fontSize: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final priceStr = _alertPriceController.text;
                    if (priceStr.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a target price.')));
                      return;
                    }
                    final targetPrice = double.tryParse(priceStr);
                    if (targetPrice == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid price format.')));
                      return;
                    }
                    setState(() {
                      _customAlerts.add({
                        'crop': _alertCrop,
                        'dir': _alertDirection,
                        'price': targetPrice,
                      });
                      _alertPriceController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Custom alert added for $_alertCrop!')));
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Set Alert', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Custom Alerts List
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Active Custom Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_customAlerts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No custom price alerts set. Add one above.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                )
              else
                ...List.generate(_customAlerts.length, (index) {
                  final alert = _customAlerts[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1))),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active, color: AppColors.primaryGreen, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🔔 ${alert['crop']} price goes ${alert['dir'].toLowerCase()} ${_fmt(alert['price'])}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _customAlerts.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Remove', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}
