class Product {
  final String name;
  final String brand;
  final String price;
  final String type; // 'seed' or 'fertilizer'
  final String cropType;

  Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.type,
    required this.cropType,
  });
}

class ProductData {
  static final Map<String, List<Product>> products = {
    'Paddy': [
      Product(name: 'Sona Masoori Paddy Seeds', brand: 'Mahyco Seeds', price: '₹320 / kg', type: 'seed', cropType: 'Paddy'),
      Product(name: 'Hybrid BPT 5204', brand: 'Nuziveedu Seeds', price: '₹280 / kg', type: 'seed', cropType: 'Paddy'),
      Product(name: 'DAP Fertilizer 50kg', brand: 'IFFCO', price: '₹1,350 / bag', type: 'fertilizer', cropType: 'Paddy'),
      Product(name: 'Urea 45kg', brand: 'NFL', price: '₹266 / bag', type: 'fertilizer', cropType: 'Paddy'),
    ],
    'Sugarcane': [
      Product(name: 'Co 86032 Sugarcane Sets', brand: 'Tamil Nadu Agri', price: '₹450 / bundle', type: 'seed', cropType: 'Sugarcane'),
      Product(name: 'NPK 15-15-15', brand: 'Coromandel', price: '₹1,650 / bag', type: 'fertilizer', cropType: 'Sugarcane'),
      Product(name: 'Potash MOP 50kg', brand: 'Chambal Fert', price: '₹1,200 / bag', type: 'fertilizer', cropType: 'Sugarcane'),
    ],
    'Cotton': [
      Product(name: 'Bollgard II Cotton Bt Seed', brand: 'Monsanto', price: '₹730 / pkt', type: 'seed', cropType: 'Cotton'),
      Product(name: 'NCS 955 Hybrid Cotton', brand: 'Nuziveedu', price: '₹680 / pkt', type: 'seed', cropType: 'Cotton'),
      Product(name: 'Single Super Phosphate 50kg', brand: 'Zuari Agro', price: '₹500 / bag', type: 'fertilizer', cropType: 'Cotton'),
    ],
    'Vegetables': [
      Product(name: 'Tomato F1 Hybrid Seeds', brand: 'East-West Seeds', price: '₹180 / 10g', type: 'seed', cropType: 'Vegetables'),
      Product(name: 'Bhendi (Okra) Seeds', brand: 'VNR Seeds', price: '₹95 / 250g', type: 'seed', cropType: 'Vegetables'),
      Product(name: '19:19:19 Water Soluble', brand: 'SQM', price: '₹420 / kg', type: 'fertilizer', cropType: 'Vegetables'),
    ],
    'Maize': [
      Product(name: 'Pioneer 30V92 Maize', brand: 'Pioneer', price: '₹1,100 / kg', type: 'seed', cropType: 'Maize'),
      Product(name: 'DKC 9108 Maize Hybrid', brand: 'Dekalb', price: '₹980 / kg', type: 'seed', cropType: 'Maize'),
      Product(name: 'Zinc Sulphate Fertilizer', brand: 'IFFCO', price: '₹380 / kg', type: 'fertilizer', cropType: 'Maize'),
    ],
    'Other': [
      Product(name: 'Groundnut TMV 7 Seeds', brand: 'TNAU', price: '₹220 / kg', type: 'seed', cropType: 'Other'),
      Product(name: 'Organic Compost 25kg', brand: 'Biofix', price: '₹360 / bag', type: 'fertilizer', cropType: 'Other'),
    ],
  };

  static List<Product> search(String query) {
    final q = query.toLowerCase();
    return products.values
        .expand((list) => list)
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.cropType.toLowerCase().contains(q))
        .toList();
  }
}
