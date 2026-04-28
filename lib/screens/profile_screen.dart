import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/language_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/custom_network_image.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSavingLocation = false;

  @override
  void initState() {
    super.initState();
  }

  void _showEditFieldDialog(BuildContext context, String title, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _showEditFieldDialog(context, 'Name', userProvider.name, (val) => userProvider.updateProfile(name: val));
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black87,
            body: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Center(
                    child: Hero(
                      tag: 'profile_image',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomNetworkImage(
                          url: imageUrl,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width,
                          fit: BoxFit.contain,
                          placeholderAsset: 'assets/images/placeholder.png',
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final lp = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Gradient Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryGreen, Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Profile',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: () => _showFullScreenImage(context, user.profileImage),
                        child: Hero(
                          tag: 'profile_image',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15)],
                            ),
                            child: CustomNetworkImage(
                              url: user.profileImage,
                              width: 120,
                              height: 120,
                              borderRadius: 60,
                              placeholderAsset: 'assets/images/placeholder.png',
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null && context.mounted) {
                            context.read<UserProvider>().updateProfile(profileImage: pickedFile.path);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: AppColors.primaryGreen, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.name,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showEditNameDialog(context),
                        child: const Icon(Icons.edit, color: Colors.white70, size: 20),
                      ),
                    ],
                  ),
                  const Text('Active Farmer',
                      style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 0.5)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Personal Info Card
                  _buildInfoCard(
                    context,
                    lp.translate('personal_info'),
                    [
                      _buildInfoRow(
                        Icons.location_on, 
                        lp.translate('location'), 
                        user.location,
                        onAction: () => _showEditFieldDialog(context, 'Location', user.location, (val) async {
                          setState(() => _isSavingLocation = true);
                          try {
                            await context.read<UserProvider>().updateProfile(location: val);
                            if (context.mounted) {
                              await context.read<WeatherProvider>().searchCity(val);
                            }
                          } finally {
                            if (mounted) setState(() => _isSavingLocation = false);
                          }
                        }),
                        actionIcon: Icons.edit,
                        onSecondaryAction: () async {
                          await context.read<UserProvider>().updateLocationFromGPS();
                          if (context.mounted) {
                            context.read<WeatherProvider>().refreshWeather();
                          }
                        },
                        secondaryActionIcon: Icons.my_location,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.phone, 
                        lp.translate('phone'), 
                        user.phone,
                        onAction: () => _showEditFieldDialog(context, 'Phone', user.phone, (val) => context.read<UserProvider>().updateProfile(phone: val)),
                        actionIcon: Icons.edit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Menu Options
                  _buildInfoCard(
                    context,
                    'Account Settings',
                    [
                      _buildMenuRow(context, Icons.help_outline, lp.translate('support'), () {}),
                      const Divider(),
                      _buildMenuRow(context, Icons.logout, lp.translate('logout'), () => _showLogoutDialog(context), isDestructive: true),
                    ],
                  ),
                ],
              ),
            ),
            if (_isSavingLocation)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryGreen),
                          SizedBox(height: 16),
                          Text('Updating Location...', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onAction, IconData? actionIcon, VoidCallback? onSecondaryAction, IconData? secondaryActionIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
          if (onSecondaryAction != null)
            IconButton(
              icon: Icon(secondaryActionIcon, size: 20, color: AppColors.primaryGreen),
              onPressed: onSecondaryAction,
            ),
          if (onAction != null)
            IconButton(
              icon: Icon(actionIcon ?? Icons.edit, size: 20, color: AppColors.primaryGreen),
              onPressed: onAction,
            ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.red : AppColors.textPrimary, size: 24),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : AppColors.textPrimary)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
