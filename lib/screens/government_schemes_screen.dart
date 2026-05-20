import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

// --- Models ---
class SchemeData {
  final String id;
  final String nameTamil;
  final String nameEnglish;
  final String category;
  final String ministry;
  final String benefits;
  final String description;
  final List<String> eligibility;
  final List<String> documents;
  final List<String> steps;
  final String applyUrl;
  final String deadline;
  final String status;

  const SchemeData({
    required this.id,
    required this.nameTamil,
    required this.nameEnglish,
    required this.category,
    required this.ministry,
    required this.benefits,
    required this.description,
    required this.eligibility,
    required this.documents,
    required this.steps,
    required this.applyUrl,
    required this.deadline,
    required this.status,
  });
}

// --- Data ---
const List<SchemeData> schemesData = [
  SchemeData(
    id: 'pmkisan',
    nameTamil: 'பிரதமர் கிசான் சம்மான் நிதி',
    nameEnglish: 'PM-KISAN',
    category: 'நிதி உதவி',
    ministry: 'விவசாய அமைச்சகம்',
    benefits: '₹6,000 ஆண்டுக்கு (₹2,000 x 3 தவணைகள்)',
    description: 'நேரடி வங்கிக் கணக்கில் பணம் செலுத்தப்படும். அனைத்து விவசாயிகளுக்கும்.',
    eligibility: [
      '2 ஹெக்டேர் வரை நிலம் உள்ள விவசாயிகள்',
      'வயது வரம்பு இல்லை',
      'வங்கி கணக்கு ஆதார் உடன் இணைக்கப்பட்டிருக்க வேண்டும்',
      'நில உரிமை இருக்க வேண்டும்'
    ],
    documents: [
      'ஆதார் அட்டை',
      'நில பத்திரம் (பட்டா/சிட்டா)',
      'வங்கி கணக்கு விவரம்',
      'புகைப்படம்'
    ],
    steps: [
      'PM-KISAN இணையதளம் திறக்கவும்',
      '"Farmer Corner" கிளிக் செய்யவும்',
      '"New Farmer Registration" தேர்ந்தெடுக்கவும்',
      'ஆதார் எண் மற்றும் மொபைல் எண் உள்ளிடவும்',
      'OTP சரிபார்க்கவும்',
      'தனிப்பட்ட மற்றும் நில விவரங்கள் நிரப்பவும்',
      'வங்கி விவரங்கள் சேர்க்கவும்',
      'ஆவணங்களை பதிவேற்றவும்',
      'சமர்ப்பிக்கவும்'
    ],
    applyUrl: 'https://pmkisan.gov.in/',
    deadline: 'நிரந்தரம் - எப்போதும் விண்ணப்பிக்கலாம்',
    status: 'active',
  ),
  SchemeData(
    id: 'pmfby',
    nameTamil: 'பிரதமர் பயிர் பாதுகாப்பு காப்பீட்டு திட்டம்',
    nameEnglish: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
    category: 'காப்பீடு',
    ministry: 'விவசாய அமைச்சகம்',
    benefits: 'பயிர் சேதம் ஏற்பட்டால் இழப்பீடு. மானாவாரி - 2%, பாசன நிலம் - 1.5% பிரீமியம்',
    description: 'இயற்கை பேரிடர், பூச்சித் தாக்குதல், நோய் காரணமாக பயிர் சேதம் ஏற்பட்டால் காப்பீட்டு பாதுகாப்பு',
    eligibility: [
      'அனைத்து விவசாயிகள் (நில உரிமையாளர் மற்றும் குத்தகை விவசாயிகள்)',
      'அறிவிக்கப்பட்ட பயிர்களை சாகுபடி செய்பவர்கள்',
      'பயிர் பருவத்தின் முதல் இரண்டு வாரங்களுக்குள் விண்ணப்பிக்க வேண்டும்'
    ],
    documents: [
      'ஆதார் அட்டை',
      'நில பத்திரம் அல்லது குத்தகை ஒப்பந்தம்',
      'வங்கி கணக்கு விவரம்',
      'விதைப்பு சான்று (கிராம நிர்வாக அலுவலர் சான்று)',
      'முந்தைய ஆண்டு காப்பீட்டு ரசீது (இருந்தால்)'
    ],
    steps: [
      'பயிர் பருவ அறிவிப்பை சரிபார்க்கவும்',
      'அருகில் உள்ள வங்கி/CSC/காப்பீட்டு நிறுவனம் செல்லவும்',
      'விண்ணப்ப படிவம் நிரப்பவும்',
      'ஆவணங்களை சமர்ப்பிக்கவும்',
      'பிரீமியம் செலுத்தவும்',
      'காப்பீட்டு ரசீது பெறவும்',
      'அல்லது ஆன்லைனில்: PMFBY Portal / CSC Digital Seva வழியாக விண்ணப்பிக்கவும்'
    ],
    applyUrl: 'https://pmfby.gov.in/',
    deadline: 'கரீஃப் - ஜூலை 31 | ரபி - டிசம்பர் 31',
    status: 'active',
  ),
  SchemeData(
    id: 'kcc',
    nameTamil: 'கிசான் கிரெடிட் கார்டு',
    nameEnglish: 'Kisan Credit Card (KCC)',
    category: 'கடன்',
    ministry: 'விவசாய அமைச்சகம்',
    benefits: 'குறைந்த வட்டியில் விவசாய கடன். ₹3 லட்சம் வரை 7% வட்டி. உடனடி கடன் வசதி.',
    description: 'விதைகள், உரங்கள், பூச்சிக்கொல்லிகள், கருவிகள் வாங்க குறுகிய கால கடன் வசதி',
    eligibility: [
      'விவசாயிகள் (சொந்த நிலம் அல்லது குத்தகை)',
      '18-75 வயது',
      'வங்கி கணக்கு இருக்க வேண்டும்',
      'நல்ல கடன் வரலாறு'
    ],
    documents: [
      'ஆதார் அட்டை',
      'PAN Card',
      'நில பத்திரம்',
      'வங்கி கணக்கு விவரம்',
      'புகைப்படம்',
      '2 பாஸ்போர்ட் அளவு படங்கள்'
    ],
    steps: [
      'உங்கள் வங்கிக் கிளையை அணுகவும் (அல்லது PACS/RRB)',
      'KCC விண்ணப்ப படிவம் பெறவும்',
      'விவரங்களை நிரப்பவும்',
      'ஆவணங்களை இணைக்கவும்',
      'வங்கி அதிகாரி சரிபார்ப்பார்',
      'கடன் வரம்பு நிர்ணயிக்கப்படும்',
      '3-7 நாட்களில் KCC Card வழங்கப்படும்',
      'ஆன்லைன் விண்ணப்பம்: PMKISAN Portal வழியாக'
    ],
    applyUrl: 'https://pmkisan.gov.in/Rpt_KCCApplication.aspx',
    deadline: 'நிரந்தரம் - எப்போதும் விண்ணப்பிக்கலாம்',
    status: 'active',
  ),
  SchemeData(
    id: 'tn_seeds',
    nameTamil: 'தமிழ்நாடு விதை மானியம்',
    nameEnglish: 'TN Seed Subsidy Scheme',
    category: 'மானியம்',
    ministry: 'தமிழ்நாடு வேளாண் துறை',
    benefits: '50% மானியம் சான்றிதழ் பெற்ற விதைகளுக்கு (அதிகபட்சம் ₹5,000/ஹெக்டேர்)',
    description: 'தரமான விதைகள் வாங்க தமிழக அரசு மானியம்',
    eligibility: [
      'தமிழ்நாட்டில் வசிக்கும் விவசாயிகள்',
      'குறைந்தபட்சம் 0.5 ஹெக்டேர் நிலம்',
      'அரசு அங்கீகரிக்கப்பட்ட விதை விற்பனையாளர்களிடம் வாங்க வேண்டும்'
    ],
    documents: [
      'ஆதார் அட்டை',
      'நில பத்திரம்',
      'வங்கி கணக்கு (பாஸ்புக் நகல்)',
      'விதை பில்/ரசீது'
    ],
    steps: [
      'அங்கீகரிக்கப்பட்ட விதை விற்பனையாளரிடம் விதை வாங்கவும்',
      'பில் பெறவும்',
      'உங்கள் வட்ட வேளாண் அலுவலரை தொடர்பு கொள்ளவும்',
      'விண்ணப்பப் படிவம் பெறவும்',
      'பில் மற்றும் ஆவணங்களை இணைக்கவும்',
      'வேளாண் அலுவலகத்தில் சமர்ப்பிக்கவும்',
      'சரிபார்ப்புக்குப் பிறகு மானியம் வங்கி கணக்கில் வரும்'
    ],
    applyUrl: 'https://www.tn.gov.in/doa',
    deadline: 'பயிர் பருவத்தின் முதல் மாதம்',
    status: 'active',
  ),
  SchemeData(
    id: 'solar_pump',
    nameTamil: 'குசும் சூரிய பம்ப் திட்டம்',
    nameEnglish: 'KUSUM Solar Pump Scheme',
    category: 'மானியம்',
    ministry: 'புதுப்பிக்கத்தக்க ஆற்றல் அமைச்சகம்',
    benefits: '90% மானியம் சூரிய பம்ப் அமைக்க (30% மத்திய + 30% மாநில + 30% வங்கி கடன்)',
    description: 'மின்சாரம் இல்லாத இடங்களில் சூரிய சக்தி பம்ப் அமைக்க மானியம்',
    eligibility: [
      'விவசாயிகள் (தனிநபர் அல்லது குழுவாக)',
      'குறைந்தபட்சம் 1 ஏக்கர் நிலம்',
      'மின்சார இணைப்பு இல்லாத பகுதிகள் முன்னுரிமை',
      'நீர் ஆதாரம் (கிணறு/போர்வெல்) இருக்க வேண்டும்'
    ],
    documents: [
      'ஆதார் அட்டை',
      'நில பத்திரம்',
      'வங்கி கணக்கு விவரம்',
      'நீர் ஆதார சான்று',
      'மின்சாரத் துறை NOC (இல்லை என்ற சான்று)'
    ],
    steps: [
      'KUSUM Portal-ல் பதிவு செய்யவும்',
      'ஆன்லைன் விண்ணப்பம் சமர்ப்பிக்கவும்',
      'ஆவணங்களை பதிவேற்றவும்',
      'வேளாண் துறை சரிபார்ப்பு',
      'அங்கீகரிக்கப்பட்ட விற்பனையாளர் தேர்வு செய்யவும்',
      'நிறுவல் முன் பணம் செலுத்தவும் (10%)',
      'சூரிய பம்ப் நிறுவப்படும்',
      'சரிபார்ப்புக்குப் பிறகு மானியம் வழங்கப்படும்'
    ],
    applyUrl: 'https://pmkusum.mnre.gov.in/',
    deadline: 'ஆண்டு முழுவதும் - Batch முறையில்',
    status: 'active',
  ),
  SchemeData(
    id: 'soil_health',
    nameTamil: 'மண் வளம் அட்டை திட்டம்',
    nameEnglish: 'Soil Health Card Scheme',
    category: 'சேவை',
    ministry: 'விவசாய அமைச்சகம்',
    benefits: 'இலவசம் - மண் பரிசோதனை மற்றும் உரப் பரிந்துரை',
    description: 'உங்கள் மண்ணின் ஊட்டச்சத்து நிலையை அறிந்து சரியான உரம் பயன்படுத்துங்கள்',
    eligibility: [
      'அனைத்து விவசாயிகள்',
      'குறைந்தபட்ச நிலம் தேவை இல்லை'
    ],
    documents: [
      'ஆதார் அட்டை',
      'நில பத்திரம்',
      'மொபைல் எண்'
    ],
    steps: [
      'அருகில் உள்ள வேளாண் அலுவலகம் செல்லவும்',
      'மண் மாதிரி சேகரிப்புக்கு பதிவு செய்யவும்',
      'அலுவலர் உங்கள் வயலுக்கு வருவார்',
      'மண் மாதிரி எடுக்கப்படும்',
      'ஆய்வகத்தில் பரிசோதனை செய்யப்படும்',
      '15-30 நாட்களில் Soil Health Card வழங்கப்படும்',
      'ஆன்லைன் விண்ணப்பம்: soilhealth.dac.gov.in'
    ],
    applyUrl: 'https://soilhealth.dac.gov.in/',
    deadline: 'நிரந்தரம்',
    status: 'active',
  ),
];

// --- Main Screen ---
class GovernmentSchemesScreen extends StatefulWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  State<GovernmentSchemesScreen> createState() => _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState extends State<GovernmentSchemesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'அனைத்தும்';

  final List<String> _categories = [
    'அனைத்தும்',
    'நிதி உதவி',
    'மானியம்',
    'கடன்',
    'காப்பீடு',
    'சேவை'
  ];

  List<SchemeData> get _filteredSchemes {
    return schemesData.where((scheme) {
      final matchesSearch = scheme.nameTamil.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          scheme.nameEnglish.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          scheme.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'அனைத்தும்' || scheme.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showSchemeDetails(SchemeData scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SchemeDetailsModal(scheme: scheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('அரசு திட்டங்கள்', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text('Government Schemes', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'திட்டம் தேடுங்கள்... (எ.கா: PM-KISAN)',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = category);
                            }
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primaryGreen,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // List of Schemes
          Expanded(
            child: _filteredSchemes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('தேடல் முடிவு இல்லை', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        Text('வேறு வார்த்தைகளால் முயற்சிக்கவும்', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredSchemes.length,
                    itemBuilder: (context, index) {
                      final scheme = _filteredSchemes[index];
                      return _SchemeCard(
                        scheme: scheme,
                        onTap: () => _showSchemeDetails(scheme),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- Scheme Card ---
class _SchemeCard extends StatelessWidget {
  final SchemeData scheme;
  final VoidCallback onTap;

  const _SchemeCard({required this.scheme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.nameTamil,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scheme.nameEnglish,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    scheme.category,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              scheme.benefits,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 8),
            Text(
              scheme.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      scheme.deadline,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Text(
                      'விவரங்கள்',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16, color: AppColors.primaryGreen),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Details Modal ---
class _SchemeDetailsModal extends StatefulWidget {
  final SchemeData scheme;

  const _SchemeDetailsModal({required this.scheme});

  @override
  State<_SchemeDetailsModal> createState() => _SchemeDetailsModalState();
}

class _SchemeDetailsModalState extends State<_SchemeDetailsModal> {
  String _activeTab = 'eligibility'; // 'eligibility', 'documents', 'steps'

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.scheme.nameTamil,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.scheme.nameEnglish,
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.scheme.ministry,
                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Benefits Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.05),
              border: Border(left: BorderSide(color: AppColors.primaryGreen, width: 4)),
            ),
            child: Text(
              widget.scheme.benefits,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
            ),
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                _buildTab('eligibility', 'தகுதி', Icons.check_circle),
                _buildTab('documents', 'ஆவணங்கள்', Icons.description),
                _buildTab('steps', 'விண்ணப்ப முறை', Icons.chevron_right),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildTabContent(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Text(
                        'கடைசி தேதி: ${widget.scheme.deadline}',
                        style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _launchUrl(widget.scheme.applyUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('இப்போதே விண்ணப்பிக்கவும்', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.open_in_new, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String id, String label, IconData icon) {
    final isActive = _activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primaryGreen : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? AppColors.primaryGreen : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppColors.primaryGreen : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'eligibility':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
                SizedBox(width: 8),
                Text('யார் விண்ணப்பிக்கலாம்?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.scheme.eligibility.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.check_circle, size: 16, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  ),
                )),
          ],
        );
      case 'documents':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.description, color: AppColors.primaryGreen, size: 20),
                SizedBox(width: 8),
                Text('தேவையான ஆவணங்கள்', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.scheme.documents.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final doc = entry.value;
                return Container(
                  width: MediaQuery.of(context).size.width / 2 - 26, // Roughly 2 columns
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('$idx', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(doc, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      case 'steps':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.chevron_right, color: AppColors.primaryGreen, size: 24),
                SizedBox(width: 8),
                Text('படிப்படியாக விண்ணப்பிக்கும் முறை', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            ...widget.scheme.steps.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final step = entry.value;
              final isLast = entry.key == widget.scheme.steps.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text('$idx', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24, top: 4),
                        child: Text(step, style: const TextStyle(fontSize: 15, height: 1.4)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
