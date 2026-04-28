import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _name = 'Farmer Name';
  String _phone = '+91 98765 43210';
  String _location = 'Fetching location...';
  String _profileImage = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop';

  UserProvider() {
    _loadProfile();
  }

  String get name => _name;
  String get phone => _phone;
  String get location => _location;
  String get profileImage => _profileImage;

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('user_name') ?? _name;
    _phone = prefs.getString('user_phone') ?? _phone;
    _location = prefs.getString('user_location') ?? _location;
    _profileImage = prefs.getString('user_profile_image') ?? _profileImage;
    
    // Sync with Firestore if logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          _name = data['name'] ?? _name;
          _phone = data['phone'] ?? _phone;
          _location = data['location'] ?? _location;
          _profileImage = data['profileImage'] ?? _profileImage;
          
          // Update local cache
          await prefs.setString('user_name', _name);
          await prefs.setString('user_phone', _phone);
          await prefs.setString('user_location', _location);
          await prefs.setString('user_profile_image', _profileImage);
        }
      } catch (e) {
        debugPrint("Error syncing Firestore profile: $e");
      }
    }
    
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _name);
    await prefs.setString('user_phone', _phone);
    await prefs.setString('user_location', _location);
    await prefs.setString('user_profile_image', _profileImage);

    // Save to Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _name,
          'phone': _phone,
          'location': _location,
          'profileImage': _profileImage,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error saving to Firestore: $e");
      }
    }
  }

  Future<void> updateProfile({String? name, String? phone, String? location, String? profileImage}) async {
    if (name != null) _name = name;
    if (phone != null) _phone = phone;
    if (location != null) _location = location;
    if (profileImage != null) _profileImage = profileImage;
    await _saveProfile();
    notifyListeners();
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _name = 'Farmer Name';
    _phone = '+91 98765 43210';
    _location = 'Fetching location...';
    _profileImage = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop';
    notifyListeners();
  }

  Future<void> updateLocationFromGPS() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String street = place.thoroughfare ?? "";
          String area = place.subLocality ?? "";
          String city = place.locality ?? "";
          String district = place.subAdministrativeArea ?? "";
          
          List<String> parts = [];
          if (street.isNotEmpty && street != area) parts.add(street);
          if (area.isNotEmpty) parts.add(area);
          if (city.isNotEmpty) parts.add(city);
          if (district.isNotEmpty && district != city) parts.add(district);
          
          _location = parts.isNotEmpty ? parts.join(", ") : city;
          _saveProfile();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error fetching location for profile: $e");
    }
  }
}
