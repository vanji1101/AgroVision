import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../theme/app_colors.dart';

class CropDiseaseScreen extends StatefulWidget {
  const CropDiseaseScreen({super.key});

  @override
  State<CropDiseaseScreen> createState() => _CropDiseaseScreenState();
}

class _CropDiseaseScreenState extends State<CropDiseaseScreen> {
  final ImagePicker _picker = ImagePicker();
  
  XFile? _imageFile;
  Uint8List? _imageBytes;
  
  bool _isLoading = false;
  Map<String, dynamic>? _predictionResult;
  String? _errorMessage;

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile;
          _imageBytes = bytes;
          _predictionResult = null;
          _errorMessage = null;
        });
        
        // Auto analyze after picking
        _analyzeImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  // Upload image to FastAPI backend
  Future<void> _analyzeImage() async {
    if (_imageFile == null || _imageBytes == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/crop-disease/predict'),
      );

      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          _imageBytes!,
          filename: _imageFile!.name,
        ),
      );

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _predictionResult = data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to analyze image.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection Error: Please ensure the backend is running.';
        _isLoading = false;
      });
    }
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
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Crop Disease Detection',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text('பயிர் நோய் கண்டறிதல்',
              style: TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Upload Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Upload Crop Image',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('Take a clear photo of affected leaves or crop',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Text('பாதிக்கப்பட்ட இலைகளின் தெளிவான புகைப்படம் எடுக்கவும்',
                      style: TextStyle(fontSize: 12, color: AppColors.textOrange)),
                  const SizedBox(height: 20),
                  
                  // Image Preview
                  if (_imageBytes != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        image: DecorationImage(
                          image: MemoryImage(_imageBytes!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  Row(
                    children: [
                      Expanded(
                        child: _uploadOption(
                          Icons.camera_alt_outlined, 
                          'Camera', 
                          'கேமரா',
                          () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _uploadOption(
                          Icons.photo_library_outlined, 
                          'Gallery', 
                          'தொகுப்பு',
                          () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Loading state
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryGreen),
                    SizedBox(height: 16),
                    Text('Analyzing crop...', 
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  ],
                ),
              ),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_errorMessage!, 
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),

            // Results Section
            if (_predictionResult != null && !_isLoading)
              _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _predictionResult!;
    final confidence = result['confidence'] as num;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Analysis Complete', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('${confidence.toStringAsFixed(1)}% Confidence Score', 
                        style: const TextStyle(fontSize: 14, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          
          _buildInfoRow('Crop', result['crop']),
          const SizedBox(height: 12),
          _buildInfoRow('Disease', result['disease'], isAlert: result['disease'] != 'Healthy'),
          
          const SizedBox(height: 24),
          const Text('Treatment & Prevention', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          
          _buildSuggestionSection(Icons.medical_services_outlined, 'Treatment', result['treatment']),
          const SizedBox(height: 12),
          _buildSuggestionSection(Icons.shield_outlined, 'Prevention', result['prevention']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAlert = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isAlert ? Colors.red.shade700 : AppColors.textPrimary,
                fontSize: 15,
              )),
        ),
      ],
    );
  }

  Widget _buildSuggestionSection(IconData icon, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }

  Widget _uploadOption(IconData icon, String label, String tamil, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.lightGreenBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primaryGreen,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.primaryGreen, size: 36),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
          const SizedBox(height: 2),
          Text(tamil, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}
