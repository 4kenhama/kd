import 'package:flutter/material.dart';
import '../utils/kd_localization.dart';
import 'kd_post_form_screen.dart';

/// KD Create Choice Screen
/// Home base for /create route
/// Users choose their action: "I'm leaving", "Stay with me", or "Looking for room"
/// Features English/French language toggle at the top

class KDCreateChoiceScreen extends StatefulWidget {
  final String currentLanguage;

  const KDCreateChoiceScreen({Key? key, this.currentLanguage = AppStrings.EN})
    : super(key: key);

  @override
  State<KDCreateChoiceScreen> createState() => _KDCreateChoiceScreenState();
}

class _KDCreateChoiceScreenState extends State<KDCreateChoiceScreen> {
  late String _currentLanguage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.get('create_title', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Language Toggle Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  _currentLanguage = _currentLanguage == AppStrings.EN
                      ? AppStrings.FR
                      : AppStrings.EN;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _currentLanguage == AppStrings.EN ? 'FR' : 'EN',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                AppStrings.get('create_subtitle', language: _currentLanguage),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Choice Cards
              Expanded(
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Option A: "I'm leaving"
                    _buildChoiceCard(
                      context,
                      icon: Icons.logout_rounded,
                      title: AppStrings.get(
                        'choice_leaving',
                        language: _currentLanguage,
                      ),
                      description: AppStrings.get(
                        'choice_leaving_desc',
                        language: _currentLanguage,
                      ),
                      onTap: () {
                        _navigateToForm(context, 'leaving');
                      },
                    ),
                    const SizedBox(height: 16),

                    // Option B: "Stay with me"
                    _buildChoiceCard(
                      context,
                      icon: Icons.home_rounded,
                      title: AppStrings.get(
                        'choice_host',
                        language: _currentLanguage,
                      ),
                      description: AppStrings.get(
                        'choice_host_desc',
                        language: _currentLanguage,
                      ),
                      onTap: () {
                        _navigateToForm(context, 'host');
                      },
                    ),
                    const SizedBox(height: 16),

                    // Option C: "Looking for room"
                    _buildChoiceCard(
                      context,
                      icon: Icons.person_search_rounded,
                      title: AppStrings.get(
                        'choice_looking',
                        language: _currentLanguage,
                      ),
                      description: AppStrings.get(
                        'choice_looking_desc',
                        language: _currentLanguage,
                      ),
                      onTap: () {
                        _navigateToForm(context, 'looking');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a single choice card
  Widget _buildChoiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.grey.shade400,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }

  /// Navigate to post form with selected choice
  void _navigateToForm(BuildContext context, String choice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KDPostFormScreen(
          selectedChoice: choice,
          currentLanguage: _currentLanguage,
        ),
      ),
    );
  }
}
