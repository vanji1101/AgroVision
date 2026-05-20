import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

class DiseaseRecord {
  final String englishName;
  final String tamilName;
  final String scientificName;
  final String severity; // High, Moderate, Low
  final String symptomsEng;
  final String symptomsTam;
  final List<String> organicRemedies;
  final List<String> chemicalRemedies;

  DiseaseRecord({
    required this.englishName,
    required this.tamilName,
    required this.scientificName,
    required this.severity,
    required this.symptomsEng,
    required this.symptomsTam,
    required this.organicRemedies,
    required this.chemicalRemedies,
  });
}

class CropDiseaseScreen extends StatefulWidget {
  const CropDiseaseScreen({super.key});

  @override
  State<CropDiseaseScreen> createState() => _CropDiseaseScreenState();
}

class _CropDiseaseScreenState extends State<CropDiseaseScreen> {
  XFile? _selectedImage;
  bool _isScanning = false;
  double _scanProgress = 0.0;
  String _scanStatusText = '';
  String _scanStatusTamilText = '';
  bool _showReport = false;
  String _activeRemedyTab = 'organic'; // organic, chemical

  final ImagePicker _picker = ImagePicker();

  // Mock biological disease databases
  final List<DiseaseRecord> _diseases = [
    DiseaseRecord(
      englishName: 'Rice Blast',
      tamilName: 'அரிசி குலை நோய்',
      scientificName: 'Magnaporthe oryzae',
      severity: 'High',
      symptomsEng: 'Spindle-shaped lesions with grey centers and dark brown borders appear on leaf surfaces. Severely infected leaves dry up and die rapidly.',
      symptomsTam: 'இலைகளில் கதிர் வடிவில் நரைத்த சாம்பல் நிற மையப் பகுதியுடனும், அடர் பழுப்பு நிற ஓரங்களுடனும் புள்ளிகள் தோன்றும். தாக்குதல் அதிகமானால் இலைகள் காய்ந்துவிடும்.',
      organicRemedies: [
        'Apply Pseudomonas fluorescens powder formulation @ 10g/litre of water as a foliar spray.',
        'Spray Neem oil @ 3% or Neem Seed Kernel Extract @ 5% twice at 10 days interval.',
        'Avoid excessive application of nitrogenous fertilizers.',
      ],
      chemicalRemedies: [
        'Spray Tricyclazole 75 WP @ 1g/litre at the first sign of symptoms.',
        'Spray Azoxystrobin 25 SC @ 1ml/litre of water if blast lesions spread rapidly.',
      ],
    ),
    DiseaseRecord(
      englishName: 'Tomato Late Blight',
      tamilName: 'தக்காளி பின்கருகல் நோய்',
      scientificName: 'Phytophthora infestans',
      severity: 'Critical',
      symptomsEng: 'Water-soaked grey-green spots appearing on lower leaves, rapidly expanding into large brown lesions with fuzzy white mold on the underside during humid weather.',
      symptomsTam: 'கீழ் இலைகளில் நீர் நனைத்த சாம்பல்-பச்சை புள்ளிகள் தோன்றி, விரைவாக பெரிய பழுப்பு நிறமாக மாறும். ஈரப்பதமான காலநிலையில் இலையின் அடியில் வெண்மையான பூஞ்சை வளரும்.',
      organicRemedies: [
        'Spray Copper Oxychloride @ 2.5g/litre of water to control early fungal infestation.',
        'Apply Trichoderma viride bio-fungicide in soil @ 2.5 kg/hectare mixed with farmyard manure.',
        'Ensure wider spacing between tomato crops to permit dry airflow.',
      ],
      chemicalRemedies: [
        'Foliar spray of Metalaxyl 8% + Mancozeb 64% WP @ 2g/litre of water.',
        'Apply Cymoxanil + Mancozeb @ 2g/litre under severe humid blight outbreaks.',
      ],
    ),
  ];

  late DiseaseRecord _detectedDisease;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _showReport = false;
          _isScanning = false;
          _scanProgress = 0.0;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load image. Please verify device permissions.')),
      );
    }
  }

  void _runDiagnostic() {
    if (_selectedImage == null) return;

    setState(() {
      _isScanning = true;
      _scanProgress = 0.0;
      _scanStatusText = 'Initializing scan parameters...';
      _scanStatusTamilText = 'ஸ்கேன் தயாரிப்புகள் தொடங்கப்படுகிறது...';
    });

    // Simulate multi-step diagnostic scanning loop
    Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_scanProgress < 0.25) {
          _scanProgress = 0.30;
          _scanStatusText = 'Analyzing leaf geometry & veins...';
          _scanStatusTamilText = 'இலை நரம்புகள் பகுப்பாய்வு செய்யப்படுகிறது...';
        } else if (_scanProgress < 0.60) {
          _scanProgress = 0.65;
          _scanStatusText = 'Scanning lesion patterns & color histogram...';
          _scanStatusTamilText = 'இலை புள்ளிகள் மற்றும் நிறங்கள் ஸ்கேன் செய்யப்படுகிறது...';
        } else if (_scanProgress < 0.90) {
          _scanProgress = 0.90;
          _scanStatusText = 'Querying disease model database...';
          _scanStatusTamilText = 'நோயறிதல் கணினி மாதிரியுடன் ஒப்பிடப்படுகிறது...';
        } else {
          timer.cancel();
          _isScanning = false;
          // Randomly assign one of our mock diseases as detection result
          _detectedDisease = _diseases[Random().nextInt(_diseases.length)];
          _showReport = true;
        }
      });
    });
  }

  void _resetScan() {
    setState(() {
      _selectedImage = null;
      _isScanning = false;
      _scanProgress = 0.0;
      _showReport = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Crop Disease Detection', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('பயிர் நோய் கண்டறிதல்', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!_showReport && !_isScanning) _buildUploadSection(),
            if (_isScanning) _buildScanningProgress(),
            if (_showReport) _buildDiagnosticReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Crop Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Take a clear photo of affected leaves or crop', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Text('பாதிக்கப்பட்ட இலைகளின் தெளிவான புகைப்படம் எடுக்கவும்', style: TextStyle(fontSize: 11, color: AppColors.textOrange, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          // Image preview or upload box
          if (_selectedImage == null)
            GestureDetector(
              onTap: () => _pickImage(ImageSource.camera),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBg.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4), style: BorderStyle.solid, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 42, color: AppColors.primaryGreen.withOpacity(0.8)),
                    const SizedBox(height: 10),
                    const Text('Tap to capture leaves', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textGreen)),
                    const SizedBox(height: 2),
                    const Text('இலையைப் படம் எடுக்க தட்டவும்', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(_selectedImage!.path),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _resetScan,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: AppColors.alertRed),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),

          // Selection buttons
          if (_selectedImage == null)
            Row(
              children: [
                Expanded(child: _uploadOption(Icons.camera_alt_outlined, 'Camera', 'கேமரா', () => _pickImage(ImageSource.camera))),
                const SizedBox(width: 14),
                Expanded(child: _uploadOption(Icons.photo_library_outlined, 'Gallery', 'தொகுப்பு', () => _pickImage(ImageSource.gallery))),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _runDiagnostic,
                icon: const Icon(Icons.insights, size: 18),
                label: const Text('🔍 Run AI Diagnostic', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _uploadOption(IconData icon, String label, String tamil, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.lightGreenBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryGreen, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 30),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            const SizedBox(height: 2),
            Text(tamil, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningProgress() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Small preview of leaf scanning
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_selectedImage!.path),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _scanStatusText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            _scanStatusTamilText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _scanProgress,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticReport() {
    Color severityColor = Colors.green;
    if (_detectedDisease.severity.toLowerCase() == 'high') severityColor = Colors.orange;
    if (_detectedDisease.severity.toLowerCase() == 'critical') severityColor = AppColors.alertRed;

    return Column(
      children: [
        // Main report overview card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: severityColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '${_detectedDisease.severity} Severity',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: severityColor),
                    ),
                  ),
                  const Text('AI Diagnostic Report', style: TextStyle(fontSize: 11, color: AppColors.textGreen, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 14),
              Text(_detectedDisease.englishName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              Text(_detectedDisease.tamilName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textGreen)),
              const SizedBox(height: 4),
              Text('Scientific Name: ${_detectedDisease.scientificName}', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade600)),
              const Divider(height: 24),

              // Symptoms Section
              const Text('Disease Symptoms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text(_detectedDisease.symptomsEng, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
              const SizedBox(height: 4),
              Text(_detectedDisease.symptomsTam, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
            ],
          ),
        ),

        // Remedy control actions card with subtabs
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Treatment & Recommendations', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Subtabs organic vs chemical selector
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeRemedyTab = 'organic'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _activeRemedyTab == 'organic' ? AppColors.primaryGreen.withOpacity(0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _activeRemedyTab == 'organic' ? AppColors.primaryGreen : Colors.grey.shade300),
                        ),
                        child: Text(
                          '🌱 Organic Remedies',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _activeRemedyTab == 'organic' ? FontWeight.bold : FontWeight.normal,
                            color: _activeRemedyTab == 'organic' ? AppColors.primaryGreen : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeRemedyTab = 'chemical'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _activeRemedyTab == 'chemical' ? AppColors.primaryGreen.withOpacity(0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _activeRemedyTab == 'chemical' ? AppColors.primaryGreen : Colors.grey.shade300),
                        ),
                        child: Text(
                          '🧪 Chemical Solutions',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _activeRemedyTab == 'chemical' ? FontWeight.bold : FontWeight.normal,
                            color: _activeRemedyTab == 'chemical' ? AppColors.primaryGreen : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tab contents
              if (_activeRemedyTab == 'organic')
                ..._detectedDisease.organicRemedies.map((remedy) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(remedy, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4)),
                        ),
                      ],
                    ),
                  );
                })
              else
                ..._detectedDisease.chemicalRemedies.map((remedy) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.alertRed, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(remedy, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4)),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),

        // Action controls (Scan another leaf)
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetScan,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                ),
                child: const Text('Scan Another Leaf', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
