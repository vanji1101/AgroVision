import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

class SoilAnalysisScreen extends StatefulWidget {
  const SoilAnalysisScreen({super.key});

  @override
  State<SoilAnalysisScreen> createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  XFile? _selectedReportImage;
  bool _isScanning = false;
  double _scanProgress = 0.0;
  String _scanStatusText = '';
  String _scanStatusTamilText = '';
  bool _showReport = false;
  bool _isManualEntry = false;

  // Soil parameters
  String _soilType = 'Loamy'; // Loamy, Sandy, Clayey, Alluvial
  double _pH = 6.5;
  double _nitrogen = 45.0; // kg/ha (Deficient < 50, Medium 50-100, High > 100)
  double _phosphorus = 18.0; // kg/ha (Deficient < 15, Medium 15-30, High > 30)
  double _potassium = 220.0; // kg/ha (Deficient < 120, Medium 120-280, High > 280)
  double _organicCarbon = 0.65; // % (Deficient < 0.5, Medium 0.5-0.75, High > 0.75)

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickReport(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedReportImage = pickedFile;
          _isManualEntry = false;
          _showReport = false;
          _isScanning = false;
          _scanProgress = 0.0;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load soil report. Please check device permissions.')),
      );
    }
  }

  void _runDiagnostic() {
    setState(() {
      _isScanning = true;
      _scanProgress = 0.0;
      _scanStatusText = 'Reading report metadata...';
      _scanStatusTamilText = 'அறிக்கை விவரங்கள் பெறப்படுகிறது...';
    });

    // Simulate multi-stage OCR scanning
    Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_scanProgress < 0.25) {
          _scanProgress = 0.30;
          _scanStatusText = 'Parsing Nitrogen (N), Phosphorus (P) & Potassium (K) levels...';
          _scanStatusTamilText = 'தழை, மணி, சாம்பல் சத்துக்கள் கண்டறியப்படுகிறது...';
        } else if (_scanProgress < 0.60) {
          _scanProgress = 0.65;
          _scanStatusText = 'Extracting organic carbon and soil pH values...';
          _scanStatusTamilText = 'மண்ணின் கார அமில நிலை மற்றும் கரிம கரிமம் கணக்கிடப்படுகிறது...';
        } else if (_scanProgress < 0.90) {
          _scanProgress = 0.90;
          _scanStatusText = 'Cross-referencing crop suitability matrices...';
          _scanStatusTamilText = 'பயிர் பொருத்தம் மற்றும் பரிந்துரைகள் உருவாக்கப்படுகிறது...';
        } else {
          timer.cancel();
          _isScanning = false;
          // Set simulated dynamic metrics based on randomized defaults if not entered manually
          if (!_isManualEntry) {
            final rng = Random();
            _soilType = ['Loamy', 'Clayey', 'Sandy', 'Alluvial'][rng.nextInt(4)];
            _pH = double.parse((5.5 + rng.nextDouble() * 3.0).toStringAsFixed(1));
            _nitrogen = double.parse((20 + rng.nextInt(120)).toStringAsFixed(1));
            _phosphorus = double.parse((5 + rng.nextInt(40)).toStringAsFixed(1));
            _potassium = double.parse((80 + rng.nextInt(320)).toStringAsFixed(1));
            _organicCarbon = double.parse((0.3 + rng.nextDouble() * 1.1).toStringAsFixed(2));
          }
          _showReport = true;
        }
      });
    });
  }

  // Dynamic Crop Suitability rules
  List<Map<String, dynamic>> _calculateCropSuitability() {
    final List<Map<String, dynamic>> crops = [
      {'name': 'Rice (Ponni)', 'emoji': '🌾', 'score': 0.0},
      {'name': 'Groundnut', 'emoji': '🥜', 'score': 0.0},
      {'name': 'Cotton', 'emoji': '☁️', 'score': 0.0},
      {'name': 'Tomato', 'emoji': '🍅', 'score': 0.0},
      {'name': 'Maize', 'emoji': '🌽', 'score': 0.0},
    ];

    for (var crop in crops) {
      double score = 50.0; // base

      // pH rules
      if (crop['name'] == 'Rice (Ponni)') {
        if (_pH >= 6.0 && _pH <= 7.0) score += 20;
        else if (_pH >= 5.5 && _pH <= 7.5) score += 10;
        if (_soilType == 'Clayey' || _soilType == 'Loamy') score += 20;
        if (_nitrogen > 80) score += 10;
      } else if (crop['name'] == 'Groundnut') {
        if (_pH >= 6.0 && _pH <= 7.5) score += 20;
        if (_soilType == 'Sandy' || _soilType == 'Loamy') score += 20;
        if (_phosphorus > 25) score += 10;
      } else if (crop['name'] == 'Cotton') {
        if (_pH >= 6.5 && _pH <= 8.0) score += 20;
        if (_soilType == 'Clayey' || _soilType == 'Loamy') score += 20;
        if (_potassium > 200) score += 10;
      } else if (crop['name'] == 'Tomato') {
        if (_pH >= 6.0 && _pH <= 6.8) score += 20;
        if (_soilType == 'Loamy') score += 20;
        if (_organicCarbon > 0.7) score += 10;
      } else if (crop['name'] == 'Maize') {
        if (_pH >= 5.5 && _pH <= 7.5) score += 20;
        if (_soilType == 'Alluvial' || _soilType == 'Loamy') score += 20;
        if (_nitrogen > 70) score += 10;
      }

      crop['score'] = min(98.0, max(40.0, score)).roundToDouble();
    }

    crops.sort((a, b) => b['score'].compareTo(a['score']));
    return crops;
  }

  // Fertilizer recommendations
  List<String> _getFertilizerPrescriptions() {
    final List<String> list = [];

    if (_nitrogen < 50) {
      list.add('🔴 Nitrogen is Low: Apply Urea @ 120 kg/ha in 3 split doses (basal, tillering, and panicle initiation stages).');
    } else if (_nitrogen < 100) {
      list.add('🟡 Nitrogen is Medium: Apply Urea @ 80 kg/ha to maintain soil fertility.');
    }

    if (_phosphorus < 15) {
      list.add('🔴 Phosphorus is Low: Apply Single Super Phosphate (SSP) @ 150 kg/ha as a basal dose before sowing.');
    } else if (_phosphorus < 30) {
      list.add('🟡 Phosphorus is Medium: Apply Single Super Phosphate (SSP) @ 90 kg/ha.');
    }

    if (_potassium < 120) {
      list.add('🔴 Potassium is Low: Apply Muriate of Potash (MOP) @ 60 kg/ha in 2 split doses.');
    } else if (_potassium < 280) {
      list.add('🟡 Potassium is Medium: Apply Muriate of Potash (MOP) @ 40 kg/ha.');
    }

    if (_organicCarbon < 0.5) {
      list.add('🌱 Organic Carbon is Deficient: Incorporate well-decomposed Farmyard Manure (FYM) @ 12.5 t/ha or apply green leaf manures.');
    } else if (_organicCarbon < 0.75) {
      list.add('🌱 Organic Carbon is Moderate: Apply Vermicompost @ 5 t/ha or sow legume green manures.');
    }

    if (_pH < 6.0) {
      list.add('⚠️ Soil is Acidic (pH < 6.0): Apply Agricultural Lime (CaCO3) @ 500 kg/ha during field preparation to neutralize acidity.');
    } else if (_pH > 7.8) {
      list.add('⚠️ Soil is Alkaline (pH > 7.8): Apply Gypsum @ 500 kg/ha during layout setting to lower soil pH levels.');
    }

    if (list.isEmpty) {
      list.add('🟢 Soil nutrients are perfectly balanced! Maintain current organic carbon with regular crop rotation.');
    }

    return list;
  }

  // Visual Helper Elements
  Widget _buildCard({required Widget child, Color? color, EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }

  Widget _buildMeterItem(String title, double val, double minV, double maxV, String suffix, String status, Color col) {
    double ratio = (val - minV) / (maxV - minV);
    ratio = min(1.0, max(0.0, ratio));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Row(
                children: [
                  Text('${val.toString()}$suffix', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: col)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(col),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  void _resetScreen() {
    setState(() {
      _selectedReportImage = null;
      _isManualEntry = false;
      _isScanning = false;
      _showReport = false;
      _pH = 6.5;
      _nitrogen = 45.0;
      _phosphorus = 18.0;
      _potassium = 220.0;
      _organicCarbon = 0.65;
    });
  }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Soil Analysis', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('மண் பகுப்பாய்வு', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!_showReport && !_isScanning && !_isManualEntry) _buildSelectionSection(),
            if (_isManualEntry && !_showReport && !_isScanning) _buildManualFormSection(),
            if (_isScanning) _buildScanningProgress(),
            if (_showReport) _buildHealthReportSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection() {
    return Column(
      children: [
        _buildCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upload Soil Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Upload your soil test report or enter details manually', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Text('மண் சோதனை அறிக்கையை பதிவேற்றவும்', style: TextStyle(fontSize: 11, color: AppColors.textOrange, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),

              // Upload report click box
              GestureDetector(
                onTap: () => _pickReport(ImageSource.gallery),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF5EF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.soilBrown.withOpacity(0.4), style: BorderStyle.solid, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.upload_file, color: AppColors.soilBrown, size: 42),
                      const SizedBox(height: 10),
                      const Text('Upload PDF/Image Report', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.soilBrown)),
                      const SizedBox(height: 2),
                      Text('அறிக்கையை பதிவேற்றவும்', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Split uploader and manual inputs
        Row(
          children: [
            Expanded(
              child: _uploadOption(Icons.camera_alt_outlined, 'Scan via Camera', 'கேமரா மூலம் ஸ்கேன்', () => _pickReport(ImageSource.camera)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _uploadOption(Icons.edit_note_outlined, 'Enter Manually', 'கைமுறையாக உள்ளிடவும்', () {
                setState(() {
                  _isManualEntry = true;
                  _showReport = false;
                });
              }),
            ),
          ],
        ),

        if (_selectedReportImage != null) ...[
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Selected report: ${_selectedReportImage!.name.split('/').last}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.alertRed, size: 18),
                      onPressed: () => setState(() => _selectedReportImage = null),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _runDiagnostic,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.soilBrown, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('🔍 Run Health Scan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _uploadOption(IconData icon, String label, String tamil, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF5EF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.soilBrown, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(icon, color: AppColors.soilBrown, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.soilBrown)),
            const SizedBox(height: 2),
            Text(tamil, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildManualFormSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Soil Parameters Form', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              TextButton(onPressed: _resetScreen, child: const Text('Back', style: TextStyle(fontSize: 12, color: AppColors.soilBrown, fontWeight: FontWeight.bold))),
            ],
          ),
          const Divider(),

          // Soil Type dropdown
          const Text('Soil Type (மண் வகை)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _soilType,
                isExpanded: true,
                items: ['Loamy', 'Clayey', 'Sandy', 'Alluvial'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
                onChanged: (v) => setState(() => _soilType = v!),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // pH level slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Soil pH Level (கார அமில நிலை)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Text(_pH.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.soilBrown)),
            ],
          ),
          Slider(
            value: _pH,
            min: 4.0,
            max: 10.0,
            divisions: 60,
            activeColor: AppColors.soilBrown,
            inactiveColor: Colors.grey.shade200,
            onChanged: (v) => setState(() => _pH = double.parse(v.toStringAsFixed(1))),
          ),

          // Nitrogen slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nitrogen (N) - தழைச்சத்து', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Text('${_nitrogen.toInt()} kg/ha', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.soilBrown)),
            ],
          ),
          Slider(
            value: _nitrogen,
            min: 10.0,
            max: 150.0,
            divisions: 140,
            activeColor: AppColors.soilBrown,
            inactiveColor: Colors.grey.shade200,
            onChanged: (v) => setState(() => _nitrogen = double.parse(v.toStringAsFixed(0))),
          ),

          // Phosphorus slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phosphorus (P) - மணிச்சத்து', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Text('${_phosphorus.toInt()} kg/ha', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.soilBrown)),
            ],
          ),
          Slider(
            value: _phosphorus,
            min: 2.0,
            max: 50.0,
            divisions: 48,
            activeColor: AppColors.soilBrown,
            inactiveColor: Colors.grey.shade200,
            onChanged: (v) => setState(() => _phosphorus = double.parse(v.toStringAsFixed(0))),
          ),

          // Potassium slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Potassium (K) - சாம்பல் சத்து', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Text('${_potassium.toInt()} kg/ha', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.soilBrown)),
            ],
          ),
          Slider(
            value: _potassium,
            min: 50.0,
            max: 400.0,
            divisions: 350,
            activeColor: AppColors.soilBrown,
            inactiveColor: Colors.grey.shade200,
            onChanged: (v) => setState(() => _potassium = double.parse(v.toStringAsFixed(0))),
          ),

          // Organic Carbon slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Organic Carbon (OC) - கரிம கரிமம்', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Text('${_organicCarbon.toString()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.soilBrown)),
            ],
          ),
          Slider(
            value: _organicCarbon,
            min: 0.1,
            max: 1.5,
            divisions: 140,
            activeColor: AppColors.soilBrown,
            inactiveColor: Colors.grey.shade200,
            onChanged: (v) => setState(() => _organicCarbon = double.parse(v.toStringAsFixed(2))),
          ),
          const SizedBox(height: 16),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _runDiagnostic,
              icon: const Icon(Icons.insights, size: 18),
              label: const Text('🔍 Run AI Assessment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.soilBrown, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningProgress() {
    return _buildCard(
      child: Column(
        children: [
          const SizedBox(height: 12),
          const SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(color: AppColors.soilBrown, strokeWidth: 4),
          ),
          const SizedBox(height: 24),
          Text(_scanStatusText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(_scanStatusTamilText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _scanProgress,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.soilBrown),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthReportSection() {
    // Math logic calculation of health score
    double nFactor = (_nitrogen / 150) * 20;
    double pFactor = (_phosphorus / 50) * 20;
    double kFactor = (_potassium / 400) * 20;
    double ocFactor = (_organicCarbon / 1.5) * 20;
    double phFactor = (7.0 - (_pH - 7.0).abs()) / 7.0 * 20;
    int healthScore = min(98, max(38, (nFactor + pFactor + kFactor + ocFactor + phFactor).round()));

    Color scoreColor = Colors.green;
    String healthStatus = 'Excellent';
    if (healthScore < 60) {
      scoreColor = AppColors.alertRed;
      healthStatus = 'Deficient';
    } else if (healthScore < 80) {
      scoreColor = Colors.orange;
      healthStatus = 'Good';
    }

    final suitability = _calculateCropSuitability();
    final prescriptions = _getFertilizerPrescriptions();

    return Column(
      children: [
        // Health score card
        _buildCard(
          child: Row(
            children: [
              // Circular score widget
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scoreColor.withOpacity(0.08),
                  border: Border.all(color: scoreColor, width: 3.5),
                ),
                alignment: Alignment.center,
                child: Text('$healthScore', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: scoreColor)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Soil Health Index (SHI)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Status: $healthStatus Soil (வள நிலை)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: scoreColor)),
                    const SizedBox(height: 2),
                    Text('Soil Classification: $_soilType Soil Type', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Nutrient Dashboard List
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Soil Chemical Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildMeterItem('Nitrogen (N) - தழைச்சத்து', _nitrogen, 10, 150, ' kg/ha', _nitrogen < 50 ? 'Deficient' : _nitrogen < 100 ? 'Optimal' : 'Sufficient', _nitrogen < 50 ? Colors.red : _nitrogen < 100 ? Colors.green : Colors.blue),
              _buildMeterItem('Phosphorus (P) - மணிச்சத்து', _phosphorus, 2, 50, ' kg/ha', _phosphorus < 15 ? 'Deficient' : _phosphorus < 30 ? 'Optimal' : 'Sufficient', _phosphorus < 15 ? Colors.red : _phosphorus < 30 ? Colors.green : Colors.blue),
              _buildMeterItem('Potassium (K) - சாம்பல் சத்து', _potassium, 50, 400, ' kg/ha', _potassium < 120 ? 'Deficient' : _potassium < 280 ? 'Optimal' : 'Sufficient', _potassium < 120 ? Colors.red : _potassium < 280 ? Colors.green : Colors.blue),
              _buildMeterItem('Organic Carbon (OC)', _organicCarbon, 0.1, 1.5, '%', _organicCarbon < 0.5 ? 'Deficient' : _organicCarbon < 0.75 ? 'Optimal' : 'Sufficient', _organicCarbon < 0.5 ? Colors.red : _organicCarbon < 0.75 ? Colors.green : Colors.blue),
              _buildMeterItem('Soil pH Level', _pH, 4.0, 10.0, '', _pH < 6.0 ? 'Acidic' : _pH < 7.5 ? 'Neutral' : 'Alkaline', _pH < 6.0 ? Colors.orange : _pH < 7.5 ? Colors.green : Colors.deepOrange),
            ],
          ),
        ),

        // Crop Suitability ratings
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Suggested Crops Suitability Index', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...suitability.map((crop) {
                final double score = crop['score'];
                Color itemCol = Colors.green;
                if (score < 60) itemCol = Colors.red;
                else if (score < 80) itemCol = Colors.amber.shade700;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(crop['emoji'], style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(crop['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      Text('${score.toInt()}% Match', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: itemCol)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Treatment Prescriptions
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fertilizer & Treatment Advice', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...prescriptions.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.chevron_right, color: AppColors.soilBrown, size: 18),
                      const SizedBox(width: 6),
                      Expanded(child: Text(p, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Reset button
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetScreen,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: AppColors.soilBrown, width: 1.5),
                ),
                child: const Text('Analyze New Soil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.soilBrown)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
