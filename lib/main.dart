import 'package:flutter/material.dart';
import 'screens/kd_create_choice_screen.dart';
import 'screens/kd_inbox_screen.dart';
import 'screens/kd_landing_screen.dart';
import 'screens/kd_match_screen.dart';
import 'screens/kd_update_gate_screen.dart';
import 'services/kd_security_gate.dart';
import 'utils/kd_localization.dart';
import 'screens/kd_leases_feed_screen.dart';

void main() {
  KDSecurityGate.initialize();
  runApp(const KDApp());
}

class KDApp extends StatelessWidget {
  const KDApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const LandingScreen(),
    );
  }
}

class KDSecurityWrapper extends StatelessWidget {
  const KDSecurityWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (KDSecurityGate.isUpdateRequired) {
      return const KDUpdateGateScreen();
    }
    return const KDMainApp();
  }
}

class KDMainApp extends StatefulWidget {
  const KDMainApp({Key? key}) : super(key: key);

  @override
  State<KDMainApp> createState() => _KDMainAppState();
}

class _KDMainAppState extends State<KDMainApp> {
  String _currentLanguage = AppStrings.EN;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      KDLeasesFeedScreen(currentLanguage: _currentLanguage),
      KDCreateChoiceScreen(currentLanguage: _currentLanguage),
      KDMatchScreen(currentLanguage: _currentLanguage),
      KDInboxScreen(currentLanguage: _currentLanguage),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: AppStrings.get('nav_feed', language: _currentLanguage),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_rounded),
            label: AppStrings.get('nav_post', language: _currentLanguage),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_alt_rounded),
            label: AppStrings.get('nav_match', language: _currentLanguage),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.mail_rounded),
            label: AppStrings.get('nav_inbox', language: _currentLanguage),
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
