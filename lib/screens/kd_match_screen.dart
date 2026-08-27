import 'package:flutter/material.dart';
import '../utils/kd_localization.dart';

/// KD Match Screen (Roommate Matching)
/// Browse and connect with potential roommates

class KDMatchScreen extends StatefulWidget {
  final String currentLanguage;

  const KDMatchScreen({Key? key, required this.currentLanguage})
    : super(key: key);

  @override
  State<KDMatchScreen> createState() => _KDMatchScreenState();
}

class _KDMatchScreenState extends State<KDMatchScreen> {
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
          AppStrings.get('match_title', language: _currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              AppStrings.get('match_subtitle', language: _currentLanguage),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get('match_no_profiles', language: _currentLanguage),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
