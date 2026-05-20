import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product_model.dart';

class SeedFertilizerScreen extends StatefulWidget {
  const SeedFertilizerScreen({super.key});

  @override
  State<SeedFertilizerScreen> createState() => _SeedFertilizerScreenState();
}

class _SeedFertilizerScreenState extends State<SeedFertilizerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCrop = 'Paddy';
  List<Product> _displayedProducts = [];
  bool _isSearching = false;

  final List<String> _cropTypes = ['Paddy', 'Sugarcane', 'Cotton', 'Vegetables', 'Maize', 'Other'];

  final List<Map<String, dynamic>> _platforms = [
    {'name': 'Amazon', 'color': Color(0xFFFF9900), 'icon': Icons.shopping_bag_outlined, 'url': 'https://www.amazon.in/s?k='},
    {'name': 'Flipkart', 'color': Color(0xFF2874F0), 'icon': Icons.store_outlined, 'url': 'https://www.flipkart.com/search?q='},
    {'name': 'JioMart', 'color': Color(0xFFE31837), 'icon': Icons.local_grocery_store_outlined, 'url': 'https://www.jiomart.com/search/'},
    {'name': 'BigBasket', 'color': Color(0xFF84C225), 'icon': Icons.eco_outlined, 'url': 'https://www.bigbasket.com/ps/?q='},
    {'name': 'IndiaMart', 'color': Color(0xFF0066CC), 'icon': Icons.business_outlined, 'url': 'https://www.indiamart.com/search.mp?ss='},
    {'name': 'Agribazaar', 'color': Color(0xFF4CAF50), 'icon': Icons.agriculture_outlined, 'url': 'https://www.agribazaar.com/search?q='},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _displayedProducts = ProductData.products[_selectedCrop] ?? [];
      _isSearching = false;
    });
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      _loadProducts();
      return;
    }
    setState(() {
      _displayedProducts = ProductData.search(query);
      _isSearching = true;
    });
  }

  void _showPlatformPicker(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PlatformPickerSheet(
        product: product,
        platforms: _platforms,
        onPlatformSelected: (platform) => _redirectToPlatform(product, platform),
      ),
    );
  }

  Future<void> _redirectToPlatform(Product product, Map<String, dynamic> platform) async {
    final query = Uri.encodeComponent('${product.name} buy online India');
    final url = Uri.parse('${platform['url']}$query');
    Navigator.pop(context);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open ${platform['name']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    if (!_isSearching) ...[
                      _buildSectionLabel('Select Crop Type'),
                      const SizedBox(height: 8),
                      _buildCropChips(),
                      const SizedBox(height: 16),
                    ],
                    _buildSectionLabel(
                      _isSearching
                          ? 'Search Results (${_displayedProducts.length})'
                          : 'Products for $_selectedCrop',
                    ),
                    const SizedBox(height: 8),
                    _buildProductList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF1a6b3c),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: const Row(
        children: [
          Icon(Icons.eco, color: Colors.white, size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Seeds & Fertilizers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.shopping_cart_outlined, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search seeds, fertilizers...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1a6b3c), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _loadProducts();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCropChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _cropTypes.map((crop) {
        final isSelected = crop == _selectedCrop;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedCrop = crop);
            _loadProducts();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1a6b3c) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF1a6b3c) : Colors.grey[300]!,
              ),
            ),
            child: Text(
              '${_cropEmoji(crop)} $crop',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _cropEmoji(String crop) {
    const map = {
      'Paddy': '🌾', 'Sugarcane': '🌿', 'Cotton': '☁️',
      'Vegetables': '🥬', 'Maize': '🌽', 'Other': '🌱'
    };
    return map[crop] ?? '🌱';
  }

  Widget _buildProductList() {
    if (_displayedProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text('No products found', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }
    return Column(
      children: _displayedProducts
          .map((product) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProductCard(
                  product: product,
                  onBuyNow: () => _showPlatformPicker(product),
                ),
              ))
          .toList(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onBuyNow;

  const _ProductCard({required this.product, required this.onBuyNow});

  @override
  Widget build(BuildContext context) {
    final isSeed = product.type == 'seed';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSeed ? const Color(0xFFEAF3DE) : const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(isSeed ? '🌱' : '🧪', style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(product.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSeed ? const Color(0xFFEAF3DE) : const Color(0xFFE6F1FB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isSeed ? 'Seed' : 'Fert',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSeed ? const Color(0xFF3B6D11) : const Color(0xFF185FA5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(product.brand, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text(product.price,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1a6b3c))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onBuyNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1a6b3c),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Buy Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _PlatformPickerSheet extends StatelessWidget {
  final Product product;
  final List<Map<String, dynamic>> platforms;
  final Function(Map<String, dynamic>) onPlatformSelected;

  const _PlatformPickerSheet({
    required this.product,
    required this.platforms,
    required this.onPlatformSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('Choose Platform', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(product.name,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: platforms.map((p) => _PlatformTile(platform: p, onTap: () => onPlatformSelected(p))).toList(),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  final Map<String, dynamic> platform;
  final VoidCallback onTap;

  const _PlatformTile({required this.platform, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: (platform['color'] as Color).withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: (platform['color'] as Color).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(platform['icon'] as IconData, color: platform['color'] as Color, size: 26),
            const SizedBox(height: 6),
            Text(platform['name'] as String,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: platform['color'] as Color)),
          ],
        ),
      ),
    );
  }
}
