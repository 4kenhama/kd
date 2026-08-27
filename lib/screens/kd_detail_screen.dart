import 'package:flutter/material.dart';
import '../models/kd_listing_model.dart';
import '../utils/kd_localization.dart';
import 'kd_inbox_screen.dart';

class KDDetailScreen extends StatelessWidget {
  final KDListing listing;
  final String currentLanguage;

  const KDDetailScreen({
    Key? key,
    required this.listing,
    required this.currentLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String location = '${listing.town}, ${listing.streetName}';

    return Scaffold(
      appBar: AppBar(title: const Text('Listing'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (listing.imagePaths.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    listing.imagePaths.first,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_rounded),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.home_work_rounded, size: 52),
                  ),
                ),
              const SizedBox(height: 20),

              const SizedBox(height: 12),
              Text(
                listing.formattedPrice,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(
                    listing.waterAvailable ? '💧 Water' : '🚫 Water',
                    listing.waterAvailable
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    listing.waterAvailable
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                  _chip(
                    listing.electricityType == ElectricityType.prepaidMeter
                        ? '⚡ Prepaid Meter'
                        : '⚡ Shared Meter',
                    Colors.blue.shade50,
                    Colors.blue.shade700,
                  ),
                  _chip(
                    listing.kitchenType == KitchenType.internalKitchen
                        ? '🍳 Internal Kitchen'
                        : '🍳 No Kitchen',
                    Colors.orange.shade50,
                    Colors.orange.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                listing.generalDescription,
                style: const TextStyle(height: 1.6, color: Colors.black87),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final message = _buildLocalizedGreeting(listing);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KDInboxScreen(
                          currentLanguage: currentLanguage,

                          prefilledMessage: message,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.message_rounded, color: Colors.white),
                  label: const Text(
                    "I'm Interested — Message",
                    style: TextStyle(
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
    );
  }

  Widget _chip(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _buildLocalizedGreeting(KDListing listing) {
    final location = '${listing.town}, ${listing.streetName}';
    final price = listing.formattedPrice;

    if (currentLanguage == AppStrings.FR) {
      return 'Bonjour, je suis intéressé(e) par votre annonce  à $location. Le loyer est de $price. Je souhaite discuter de l’échange de bail et de la visite. Merci !';
    }

    return 'Hello, I am interested in your listing  in $location. The rent is $price. I would like to discuss the lease swap and arrange a viewing. Thank you!';
  }
}
