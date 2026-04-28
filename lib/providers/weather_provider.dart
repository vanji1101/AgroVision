import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import '../services/crop_advice_service.dart';
import '../services/disease_prediction_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _weather;
  bool _isLoading = false;
  String? _error;
  String _selectedCrop = 'நெல்';
  List<String> _diseaseRisks = [];

  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCrop => _selectedCrop;
  List<String> get diseaseRisks => _diseaseRisks;

  final WeatherService _weatherService = WeatherService();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  WeatherProvider() {
    _initNotifications();
  }

  void setSelectedCrop(String crop) {
    _selectedCrop = crop;
    notifyListeners();
  }

  Future<void> _initNotifications() async {
    // Request notification permission for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'weather_alerts',
      'Weather Alerts',
      channelDescription: 'Notifications for weather disasters',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> refreshWeather({double? lat, double? lon, String? locationName}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      double targetLat, targetLon;
      String? targetName = locationName;
      final prefs = await SharedPreferences.getInstance();

      // Priority 1: Use provided coordinates (from searchCity or GPS button)
      if (lat != null && lon != null) {
        targetLat = lat;
        targetLon = lon;
        targetName = targetName ?? prefs.getString('user_location');
      } 
      // Priority 2: Use Profile Location string from SharedPreferences
      else {
        String? profileLoc = prefs.getString('user_location');
        
        if (profileLoc != null && profileLoc.isNotEmpty && 
            profileLoc != 'Current Location' && profileLoc != 'Coimbatore, Tamil Nadu') {
          try {
            // Append region to improve geocoding accuracy for Tamil Nadu towns
            List<Location> locations = await locationFromAddress("$profileLoc, Tamil Nadu, India");
            if (locations.isNotEmpty) {
              targetLat = locations[0].latitude;
              targetLon = locations[0].longitude;
              targetName = profileLoc;
            } else {
              throw Exception("Location not found");
            }
          } catch (e) {
            // District coordinates fallback for Tamil Nadu
            final districts = {
              'perambalur': [11.2342, 78.8820],
              'kodaikanal': [10.2381, 77.4892],
              'cuddalore': [11.7480, 79.7714],
              'chennai': [13.0827, 80.2707],
              'madurai': [9.9252, 78.1198],
              'coimbatore': [11.0168, 76.9558],
              'trichy': [10.7905, 78.7047],
              'salem': [11.6643, 78.1460],
              'thanjavur': [10.7870, 79.1378],
            };

            String key = profileLoc.toLowerCase();
            if (districts.containsKey(key)) {
              targetLat = districts[key]![0];
              targetLon = districts[key]![1];
            } else {
              targetLat = prefs.getDouble('last_lat') ?? 11.0168;
              targetLon = prefs.getDouble('last_lon') ?? 76.9558;
            }
            targetName = profileLoc;
          }
        } 
        // Priority 3: Fallback to GPS
        else {
          Position position = await _determinePosition();
          targetLat = position.latitude;
          targetLon = position.longitude;
          targetName = null; // Let reverse geocoding determine the name
        }
      }

      // Save the final determined coordinates for persistence
      await prefs.setDouble('last_lat', targetLat);
      await prefs.setDouble('last_lon', targetLon);
      if (targetName != null) {
        await prefs.setString('last_location_name', targetName);
      }

      _weather = await _weatherService.fetchWeather(targetLat, targetLon, manualName: targetName);
      
      // Calculate Disease Risks
      _diseaseRisks = DiseasePredictionService.predict(
        crop: _selectedCrop,
        temp: _weather!.temperature,
        humidity: _weather!.humidity,
        rain: _weather!.rainProbability, // actually using precipitation_probability max here, which is fine, or we could use rain
      );

      // Show alert notifications
      if (_weather?.alert.isNotEmpty ?? false) {
        _showNotification("⚠️ Weather Alert", _weather!.alert);
      }

      // Show disease notifications
      for (var risk in _diseaseRisks) {
        _showNotification("🦠 Disease Warning", risk);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    } 

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<void> searchCity(String cityName) async {
    _isLoading = true;
    _weather = null; // Clear old weather to avoid confusion
    _error = null;
    notifyListeners();

    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        await refreshWeather(
          lat: locations[0].latitude,
          lon: locations[0].longitude,
          locationName: cityName,
        );
      } else {
        throw Exception('Location not found');
      }
    } catch (e) {
      _error = "Could not find '$cityName'. Please check spelling.";
      _isLoading = false;
      notifyListeners();
    }
  }

  String getCropAdvice() {
    if (_weather == null) return "Loading advice...";
    
    return CropAdviceService.getAdvice(
      crop: _selectedCrop,
      temp: _weather!.temperature,
      humidity: _weather!.humidity,
      wind: _weather!.windSpeed,
      rain: _weather!.rainProbability,
    );
  }
}
