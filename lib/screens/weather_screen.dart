import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WeatherProvider>().refreshWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.weather;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search city (e.g. Madurai)...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.read<WeatherProvider>().searchCity(value);
                    setState(() => _isSearching = false);
                  }
                },
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Farmer Weather Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('விவசாயி வானிலை எச்சரிக்கை', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ]),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () => weatherProvider.refreshWeather(),
          ),
        ],
      ),
      body: weatherProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : weatherProvider.error != null
              ? Center(child: Text('Error: ${weatherProvider.error}'))
              : weather == null
                  ? const Center(child: Text('No weather data available'))
                  : RefreshIndicator(
                      onRefresh: () => weatherProvider.refreshWeather(),
                      color: AppColors.primaryGreen,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          // Compact Premium Weather Card
                          _buildCompactWeatherCard(weather),
                          
                          const SizedBox(height: 24),
                          
                          if (weather.alert.isNotEmpty) _buildAlertBanner(weather.alert),

                          _buildCropAwarenessSection(weatherProvider),
                          const SizedBox(height: 24),
                          
                          if (weatherProvider.diseaseRisks.isNotEmpty) _buildDiseaseRiskSection(weatherProvider),
                          if (weatherProvider.diseaseRisks.isNotEmpty) const SizedBox(height: 24),
                          
                          _buildHourlyForecast(weather.hourly),
                          const SizedBox(height: 24),
                          
                          _buildDailyForecast(weather.daily),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildCompactWeatherCard(WeatherData weather) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF343B54),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(weather.locationName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Current weather • ${DateFormat('h:mm a').format(DateTime.now())}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Row 2: Main Temp
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(weather.icon, style: const TextStyle(fontSize: 60)),
              const SizedBox(width: 16),
              Text('${weather.temperature.round()}°C', style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w400)),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(weather.condition, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Feels like ${weather.temperature.round() + 2}°', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Row 3: Summary
          Text('Expect ${weather.condition.toLowerCase()} skies. The high will be ${(weather.temperature + 2).round()}°.', 
            style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 24),
          
          // Row 4: Stats Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCompactStat('Wind', '${weather.windSpeed.round()} km/h'),
              _buildCompactStat('Humidity', '${weather.humidity.round()}%'),
              _buildCompactStat('Rain Prob', '${weather.rainProbability.round()}%'),
              _buildCompactStat('Dew point', '${(weather.temperature - 5).round()}°'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _getWeatherImageUrl(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('rain') || condition.contains('shower')) {
      return 'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?q=80&w=800&auto=format&fit=crop';
    } else if (condition.contains('cloud') || condition.contains('fog')) {
      return 'https://images.unsplash.com/photo-1534088568595-a066f410bcda?q=80&w=800&auto=format&fit=crop';
    } else if (condition.contains('storm') || condition.contains('thunder')) {
      return 'https://images.unsplash.com/photo-1605727216801-e27ce1d0ce3c?q=80&w=800&auto=format&fit=crop';
    } else {
      return 'https://images.unsplash.com/photo-1561484964660-8438495574c8?q=80&w=800&auto=format&fit=crop';
    }
  }

  Widget _buildQuickAccessCities(WeatherProvider wp) {
    final cities = [
      {'name': 'Current', 'icon': Icons.my_location},
      {'name': 'Panruti', 'icon': Icons.location_city},
      {'name': 'Thanjavur', 'icon': Icons.agriculture},
      {'name': 'Coimbatore', 'icon': Icons.factory_outlined},
      {'name': 'Madurai', 'icon': Icons.temple_hindu_outlined},
      {'name': 'Salem', 'icon': Icons.terrain_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Popular Cities', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              final isCurrent = city['name'] == 'Current';
              
              return GestureDetector(
                onTap: () {
                  if (isCurrent) {
                    wp.refreshWeather();
                  } else {
                    wp.searchCity(city['name'] as String);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isCurrent ? AppColors.primaryGreen : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(city['icon'] as IconData, size: 16, color: isCurrent ? Colors.white : AppColors.textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        city['name'] as String,
                        style: TextStyle(color: isCurrent ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlertBanner(String alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF5A623), Color(0xFFE8820C)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(alert, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildCropAwarenessSection(WeatherProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🌾 Crop Awareness', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: provider.selectedCrop,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGreen),
                  items: [
                    'நெல்', 'ராகி', 'கம்பு', 'சோளம்', 'உளுந்து', 
                    'கரும்பு', 'பருத்தி', 'நிலக்கடலை', 
                    'வாழை', 'மா', 'தக்காளி', 'வெங்காயம்', 
                    'தென்னை', 'முந்திரி', 'தேக்கு', 'சவுக்கு', 'கால்நடைகள்'
                  ].map((String crop) {
                    return DropdownMenuItem<String>(
                      value: crop,
                      child: Text(crop, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) provider.setSelectedCrop(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    provider.getCropAdvice(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseRiskSection(WeatherProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.biotech, color: Colors.red, size: 22),
              SizedBox(width: 8),
              Text('Disease Risk Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          ...provider.diseaseRisks.map((risk) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    risk,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(List<HourlyForecast> hourly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hourly Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourly.length,
            itemBuilder: (context, index) {
              final h = hourly[index];
              return Container(
                width: 85,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(h.time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text(h.icon, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 6),
                    Text('${h.temp.round()}°', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast(List<DailyForecast> daily) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('7-Day Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
            itemBuilder: (context, index) {
              final d = daily[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.day, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                          Text(d.tamilDay, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(d.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    if (d.rainProb > 20)
                      Text('${d.rainProb.round()}%', style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${d.highTemp.round()}°', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(width: 12),
                    Text('${d.lowTemp.round()}°', style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeatherStatW extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _WeatherStatW(this.icon, this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primaryGreen, size: 24),
    ),
    const SizedBox(height: 10),
    Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
  ]);
}

