import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/language_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/app_logo.dart';
import 'weather_screen.dart';
import 'crop_disease_screen.dart';
import 'soil_analysis_screen.dart';
import 'satellite_screen.dart';
import 'government_schemes_screen.dart';
import 'notifications_screen.dart';
import '../providers/weather_provider.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WeatherProvider>().refreshWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    final user = context.watch<UserProvider>();
    final wp = context.watch<WeatherProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<WeatherProvider>().refreshWeather();
          },
          color: AppColors.primaryGreen,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 10),
              _buildHeader(context, lp, l10n),
              const SizedBox(height: 24),
              _buildGreeting(lp, user, l10n),
              const SizedBox(height: 24),
              _buildWeatherCard(context, lp, wp, user, l10n),
              _buildAlertBanner(lp, wp),
              const SizedBox(height: 32),
              _buildSectionHeader(l10n.farm_tools),
              const SizedBox(height: 16),
              _buildFarmTools(context, lp, l10n),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, LanguageProvider lp, AppLocalizations l10n) {
    return Row(
      children: [
        const AppLogo(size: 52, circular: true),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AgroVision',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                l10n.smart_farming_assistant,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildCircularIcon(
          icon: Icons.notifications_none_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 26),
      ),
    );
  }

  // ─── Greeting ──────────────────────────────────────────────────────────────
  Widget _buildGreeting(LanguageProvider lp, UserProvider user, AppLocalizations l10n) {
    String greetingText = l10n.greeting;
    // If it's Tamil, it might be "வணக்கம், விவசாயி"
    // I'll try to keep the "Vanakkam, Farmer" style from the image
    return Text(
      greetingText,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  // ─── Weather Card ──────────────────────────────────────────────────────────
  Widget _buildWeatherCard(BuildContext context, LanguageProvider lp, WeatherProvider wp, UserProvider user, AppLocalizations l10n) {
    final weather = wp.weather;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: wp.isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_queue_outlined, size: 20, color: AppColors.textSecondary.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Text(
                  l10n.today_weather,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Decorative weather icon outline (as seen in image)
              Icon(Icons.cloud_outlined, size: 50, color: AppColors.primaryGreen.withOpacity(0.2)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather?.temperature.round() ?? "--"}°',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  weather?.condition ?? "Loading...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                user.location.isNotEmpty ? user.location : (weather?.locationName ?? 'Current Location'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _weatherStatItem(Icons.water_drop_outlined, l10n.humidity, '${weather?.humidity.round() ?? "-"}%'),
              _weatherStatItem(Icons.air, l10n.wind, '${weather?.windSpeed.round() ?? "-"} km/h'),
              _weatherStatItem(Icons.umbrella_outlined, l10n.rain, '${weather?.rainProbability.round() ?? "-"}%'),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WeatherScreen())),
            child: Row(
              children: [
                Text(
                  l10n.view_details,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.primaryGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherStatItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryGreen),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Alert Banner ──────────────────────────────────────────────────────────
  Widget _buildAlertBanner(LanguageProvider lp, WeatherProvider wp) {
    final alert = wp.weather?.alert ?? "";
    if (alert.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFF9800).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                alert,
                style: const TextStyle(color: Color(0xFFE65100), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Farm Tools ────────────────────────────────────────────────────────────
  Widget _buildFarmTools(BuildContext context, LanguageProvider lp, AppLocalizations l10n) {
    final tools = [
      _ToolItem(
        l10n.crop_disease,
        lp.currentLocale.languageCode == 'ta' ? 'பயிர் நோய்' : 'Crop Disease',
        'assets/logo/crop_disease.png',
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropDiseaseScreen())),
      ),
      _ToolItem(
        l10n.soil_analysis,
        lp.currentLocale.languageCode == 'ta' ? 'மண் பரிசோதனை' : 'Soil Analysis',
        'assets/logo/soil_analysis.png',
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoilAnalysisScreen())),
      ),
      _ToolItem(
        l10n.satellite_monitoring,
        lp.currentLocale.languageCode == 'ta' ? 'செயற்கைக்கோள்' : 'Satellite',
        'assets/logo/satellite_monitoring.png',
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SatelliteScreen())),
      ),
      _ToolItem(
        l10n.gov_schemes,
        lp.currentLocale.languageCode == 'ta' ? 'அரசு திட்டங்கள்' : 'Gov Schemes',
        'assets/logo/gov_schemes.png',
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GovernmentSchemesScreen())),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: tools.length,
      itemBuilder: (_, i) => _buildToolCard(tools[i]),
    );
  }

  Widget _buildToolCard(_ToolItem t) {
    return GestureDetector(
      onTap: t.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Image.asset(t.imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Text(
                    t.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;
  const _ToolItem(this.title, this.subtitle, this.imagePath, this.onTap);
}
