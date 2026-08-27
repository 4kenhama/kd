import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/kd_localization.dart';
import 'kd_create_choice_screen.dart';
import 'kd_leases_feed_screen.dart';
class LandingScreen extends StatefulWidget {
const LandingScreen({Key? key}) : super(key: key);
@override
State<LandingScreen> createState() => _LandingScreenState();
}
class _LandingScreenState extends State<LandingScreen> {
String _currentLanguage = AppStrings.EN;
int _carouselIndex = 0;
late Timer _carouselTimer;
// SYSTEM LOGGED STATE INTERCEPTOR
final bool _isUserLoggedIn = false;
// Community Updates Destination
final Uri _telegramChannelUri = Uri.parse('https://t.me/your_kwataman_channel');
// Support Donation Targets
final Uri _campayDonationUri = Uri.parse('https://campay.net/your_payment_link');
final Uri _bitcoinWalletUri = Uri.parse('bitcoin:your_bitcoin_wallet_address_here');
final Uri _paypalDonationUri = Uri.parse('https://paypal.me/your_paypal_username');
final List<Map<String, String>> _carouselSteps = [
{
'en': 'Skip Agent Fees! Swap directly with outgoing tenants.',
'fr': 'Évitez les frais d’agence ! Échangez directement avec le locataire.'
},
{
'en': '100% Verified Posts. Live camera verification keeps listings safe.',
'fr': 'Annonces 100% Vérifiées. Des photos en direct pour votre sécurité.'
},
{
'en': 'Explore Guest Houses & Hotels at direct local prices.',
'fr': 'Explorez les résidences et hôtels aux prix directs locaux.'
},
];
@override
void initState() {
super.initState();
_carouselTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
if (mounted) {
setState(() {
_carouselIndex = (_carouselIndex + 1) % _carouselSteps.length;
});
}
});
}
@override
void dispose() {
_carouselTimer.cancel();
super.dispose();
}
Future<void> _launchExternalUrl(Uri targetUri) async {
if (!await launchUrl(targetUri, mode: LaunchMode.externalApplication)) {
debugPrint('Could not initialize application redirect for: $targetUri');
}
}
/// Interactive Bottom Modal sheet displaying clean donation gateways
void _showDonationOptions(BuildContext context) {
showModalBottomSheet(
context: context,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
),
builder: (BuildContext bc) {
final bool isEn = _currentLanguage == AppStrings.EN;
return SafeArea(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
isEn ? 'Support the Developers n' : 'Soutenir les Développeurs n',
style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
IconButton(
icon: const Icon(Icons.close),
onPressed: () => Navigator.pop(context),
)
],
),
Text(
isEn
? 'Choose your preferred platform to send a small token of goodwill
:'
: 'Choisissez votre plateforme préférée pour envoyer un petit geste
:',
style: const TextStyle(color: Colors.grey, fontSize: 13),
),
const SizedBox(height: 20),
// GATEWAY 1: CAMPAY MOBILE MONEY (Local Orange / MTN Wallet Ecosystem)
ListTile(
leading: const CircleAvatar(
backgroundColor: Colors.orangeAccent,
child: Icon(Icons.phone_android_rounded, color: Colors.white),
),
title: Text(isEn ? 'Mobile Money (MTN / Orange via CamPay)' : 'Mobile M
oney (MTN / Orange via CamPay)'),
subtitle: Text(isEn ? 'Best option for local Cameroon wallets' : 'Idéal
pour le Cameroun local'),
trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
onTap: () {
Navigator.pop(context);
_launchExternalUrl(_campayDonationUri);
},
),
const Divider(),
// GATEWAY 2: BITCOIN (Global Crypto Network Address Node)
ListTile(
leading: const CircleAvatar(
backgroundColor: Colors.amber,
child: Icon(Icons.currency_bitcoin_rounded, color: Colors.white),
),
title: const Text('Bitcoin (Crypto Wallet)'),
subtitle: Text(isEn ? 'Direct decentralized transfer network' : 'Transf
ert décentralisé direct'),
trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
onTap: () {
Navigator.pop(context);
_launchExternalUrl(_bitcoinWalletUri);
},
),
const Divider(),
// GATEWAY 3: PAYPAL (International Processing Hub)
ListTile(
leading: const CircleAvatar(
backgroundColor: Colors.blueAccent,
child: Icon(Icons.payment_rounded, color: Colors.white),
),
title: const Text('PayPal'),
subtitle: Text(isEn ? 'International cards and account transfers' : 'Ca
rtes internationales et virements'),
trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
onTap: () {
Navigator.pop(context);
_launchExternalUrl(_paypalDonationUri);
},
),
],
),
),
);
},
);
}
@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Align(
alignment: Alignment.topRight,
child: InkWell(
onTap: () {
setState(() {
_currentLanguage = _currentLanguage == AppStrings.EN ? AppStrings.F
R : AppStrings.EN;
});
},
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
decoration: BoxDecoration(
color: Colors.grey.shade200,
borderRadius: BorderRadius.circular(999),
),
child: Text(
_currentLanguage == AppStrings.EN ? 'FR' : 'EN',
style: const TextStyle(fontWeight: FontWeight.bold),
),
),
),
),
const SizedBox(height: 32),
const Text(
'KwataMan',
style: TextStyle(
fontSize: 44,
fontWeight: FontWeight.w900,
letterSpacing: -2,
),
),
const SizedBox(height: 14),
Text(
AppStrings.get('landing_tagline', language: _currentLanguage),
style: const TextStyle(
fontSize: 26,
fontWeight: FontWeight.bold,
height: 1.25,
),
),
const SizedBox(height: 12),
Text(
AppStrings.get('landing_subtitle', language: _currentLanguage),
style: const TextStyle(
fontSize: 15,
color: Colors.grey,
height: 1.5,
),
),
const SizedBox(height: 24),
// THE BRAND BADGES ROW (Telegram Updates + Localized Multi-Option Donation
Sheet)
Row(
children: [
Expanded(
child: InkWell(
onTap: () => _launchExternalUrl(_telegramChannelUri),
borderRadius: BorderRadius.circular(12),
child: Container(
padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
decoration: BoxDecoration(
color: Colors.blue.shade50.withOpacity(0.6),
borderRadius: BorderRadius.circular(12),
border: Border.all(color: Colors.blue.shade100),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.send_rounded, size: 18, color: Colors.blue.shade80
0),
const SizedBox(width: 8),
Text(
_currentLanguage == AppStrings.EN ? 'Telegram Hub' : 'Canal
Telegram',
style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
color: Colors.blue.shade900),
),
],
),
),
),
),
const SizedBox(width: 10),
Expanded(
child: InkWell(
onTap: () => _showDonationOptions(context),
borderRadius: BorderRadius.circular(12),
child: Container(
padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
decoration: BoxDecoration(
color: Colors.orange.shade50.withOpacity(0.6),
borderRadius: BorderRadius.circular(12),
border: Border.all(color: Colors.orange.shade100),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.coffee_rounded, size: 18, color: Colors.orange.sha
de800),
const SizedBox(width: 8),
Text(
_currentLanguage == AppStrings.EN ? 'Support Devs n' : 'Sou
tenir Devs n',
style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
color: Colors.orange.shade900),
),
],
),
),
),
),
],
),
const Spacer(),
Center(
child: AnimatedSwitcher(
duration: const Duration(milliseconds: 350),
transitionBuilder: (Widget child, Animation<double> animation) {
return FadeTransition(opacity: animation, child: child);
},
child: Container(
key: ValueKey<int>(_carouselIndex),
padding: const EdgeInsets.symmetric(horizontal: 16),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(Icons.info_outline_rounded, size: 36, color: Colors.blue.sha
de700),
const SizedBox(height: 12),
Text(
_carouselSteps[_carouselIndex][_currentLanguage]!,
textAlign: Center,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
height: 1.4,
color: Colors.black87,
),
),
],
),
),
),
),
const Spacer(),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => KDLeasesFeedScreen(
currentLanguage: _currentLanguage,
),
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.blue.shade700,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)
),
),
child: Text(
AppStrings.get('landing_primary_cta', language: _currentLanguage),
style: const TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
),
),
if (_isUserLoggedIn) ...[
const SizedBox(height: 12),
SizedBox(
width: double.infinity,
child: OutlinedButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => KDCreateChoiceScreen(
currentLanguage: _currentLanguage,
),
),
);
},
style: OutlinedButton.styleFrom(
padding: const EdgeInsets.symmetric(vertical: 16),
side: BorderSide(color: Colors.blue.shade700, width: 1.5),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1
2)),
),
child: Text(
AppStrings.get('landing_secondary_cta', language: _currentLanguage)
,
style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.sh
ade700),
),
),
),
],
],
),
),
),
);
}
}
