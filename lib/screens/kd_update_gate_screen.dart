import 'package:flutter/material.dart';
import '../utils/kd_localization.dart';
import '../services/kd_security_gate.dart';

/// KD Update Gate Screen
/// Un-dismissible screen shown when app update is required
/// Locks the viewport until user updates

class KDUpdateGateScreen extends StatefulWidget {
  const KDUpdateGateScreen({Key? key}) : super(key: key);

  @override
  State<KDUpdateGateScreen> createState() => _KDUpdateGateScreenState();
}

class _KDUpdateGateScreenState extends State<KDUpdateGateScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation - force update
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Large icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    size: 60,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  AppStrings.get('gate_update_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  AppStrings.get('gate_update_message'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Version info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Current Version:'),
                          Text(
                            KDSecurityGate.currentVersion,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Required Version:'),
                          Text(
                            KDSecurityGate.minRequiredVersion,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Update Button (un-dismissible)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleUpdateNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppStrings.get('gate_update_button'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle update button tap
  /// In production, this would open App Store or Play Store
  void _handleUpdateNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening app store... (MVP mock)')),
    );

    // Simulate successful update
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // For MVP, just acknowledge update
        KDSecurityGate.simulateUpdateRequired(updateRequired: false);
        Navigator.pop(context);
      }
    });
  }
}
