/// KD Localization
/// Central dictionary for all app strings in English and French
class AppStrings {
  static const String EN = 'en';
  static const String FR = 'fr';

  /// 1. Canonical Single Source of Truth for Display Names
  static const List<String> cameroonTowns = [
    // ADAMAWA
    'Ngaoundéré',
    'Banyo',
    'Meiganga',
    'Tibati',
    'Tignère',
    'Ngaoundal',
    'Bankim',
    'Djohong',
    'Mbé',
    // CENTRE
    'Yaoundé',
    'Mbalmayo',
    'Bafia',
    'Akonolinga',
    'Eséka',
    'Obala',
    'Nanga-Eboko',
    'Soa',
    'Mbandjock',
    'Monatélé',
    'Ngoumou',
    'Ntui',
    'Akono',
    'Ayos',
    'Makak',
    'Bot-Makak',
    'Batchenga',
    // EAST
    'Bertoua',
    'Batouri',
    'Abong-Mbang',
    'Yokadouma',
    'Garoua-Boulaï',
    'Bélabo',
    'Doumé',
    'Lomié',
    'Nguelemendouka', 'Moloundou', 'Messamena', 'Betare-Oya',
    // EXTREME-NORTH
    'Maroua',
    'Kousséri',
    'Mora',
    'Mokolo',
    'Yagoua',
    'Kaélé',
    'Bogo',
    'Guidiguis',
    'Maga',
    'Blangoua',
    'Bourrha', 'Waza', 'Hina', 'Mindif',
    // LITTORAL
    'Douala',
    'Édéa',
    'Nkongsamba',
    'Mbanga',
    'Loum',
    'Melong',
    'Manjo',
    'Yabassi',
    'Mouanko',
    'Dizangué',
    'Dibombari', 'Penja',
    // NORTH
    'Garoua',
    'Guider',
    'Figuil',
    'Pitoa',
    'Lagdo',
    'Rey-Bouba',
    'Tcholliré',
    'Poli',
    'Gaschiga',
    'Ngong',
    // NORTH-WEST
    'Bamenda',
    'Kumbo',
    'Bali',
    'Bafut',
    'Wum',
    'Ndop',
    'Nkambé',
    'Fundong',
    'Batibo',
    'Jakiri',
    'Oku',
    'Mbengwi',
    // SOUTH
    'Ebolowa',
    'Kribi',
    'Sangmélima',
    'Ambam',
    'Djoum',
    'Zoétélé',
    'Ma\'an',
    'Mvangan',
    'Campo',
    'Akom II',
    // SOUTH-WEST
    'Buéa',
    'Kumba',
    'Limbé',
    'Tiko',
    'Muyuka',
    'Mamfé',
    'Mutengene',
    'Ekondo-Titi',
    'Bangem',
    'Fontem',
    'Akwaya', 'Mundemba', 'Alou',
    // WEST
    'Bafoussam',
    'Foumban',
    'Dschang',
    'Foumbot',
    'Mbouda',
    'Bafang',
    'Bangangté',
    'Bandjoun',
    'Kékem',
    'Magba', 'Bana', 'Baham', 'Bansoa', 'Bazou',
  ];

  /// 2. Cleaned Language-Agnostic Alias Map
  /// Holds ONLY unique cross-language phonetic typos and custom shorthand targets.
  static final Map<String, String> aliasMap = {
    'duala': 'Douala',
    'yaonde': 'Yaoundé',
    'yawunde': 'Yaoundé',
    'buae': 'Buéa',
    'baffoussam': 'Bafoussam',
    'gandere': 'Ngaoundéré',
    'akom': 'Akom II',
    'ekondo': 'Ekondo-Titi',
  };

  /// 3. Normalization Engine: Safely handles French accents before character filters
  static String normalizeTownText(String value) {
    var text = value.trim().toLowerCase();
    if (text.isEmpty) return '';
    // STEP 1: Process and transform French accent letters to safe plain characters first
    text = text
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[ûùü]'), 'u')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll('ç', 'c')
        .replaceAll('’', '')
        .replaceAll('\'', '');
    // STEP 2: Now strip away any lingering special symbols, leaving only valid a-z data
    return text.replaceAll(RegExp(r'[^a-z0-9\-]'), '');
  }

  /// 4. Levenshtein Distance Calculator
  /// Measures the number of edits required to match target strings.
  static int _getEditDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;
    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = _min3(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
      }
      v0 = List<int>.from(v1);
    }

    return v0[s2.length];
  }

  static int _min3(int a, int b, int c) {
    int m = a < b ? a : b;
    return m < c ? m : c;
  }

  /// 5. Main Hybrid Resolution Engine
  static String? resolveTownAlias(String value) {
    final text = normalizeTownText(value);
    if (text.isEmpty) return null;
    // A. Check intentional shorthand/aliases map first
    if (aliasMap.containsKey(text)) {
      return aliasMap[text];
    }
    // B. Check for a direct normalized match in our towns list
    for (final town in cameroonTowns) {
      if (normalizeTownText(town) == text) {
        return town;
      }
    }
    // C. Check basic typing prefix/progression matches ("yaound" -> "Yaoundé")
    for (final town in cameroonTowns) {
      final normTown = normalizeTownText(town);
      if (normTown.startsWith(text) || text.startsWith(normTown)) {
        return town;
      }
    }
    // D. DYNAMIC FUZZY FALLBACK: Calculate string distances for completely unexpected typos
    String? bestMatch;
    int lowestDistance = 999;
    // Determine strictness threshold based on query length (shorter inputs require precision)
    int maxAllowedDistance = text.length <= 4 ? 1 : 2;
    for (final town in cameroonTowns) {
      final normTown = normalizeTownText(town);
      int distance = _getEditDistance(text, normTown);
      if (distance < lowestDistance) {
        lowestDistance = distance;
        bestMatch = town;
      }
    }
    // Return the calculated match only if it passes the strict error limits
    if (lowestDistance <= maxAllowedDistance) {
      return bestMatch;
    }
    return null;
  }

  /// 6. Auto-adapting Suggestions Engine for Forms and Filters
  static List<String> suggestions(String query) {
    final text = normalizeTownText(query);
    if (text.isEmpty) return cameroonTowns;
    // First filter using standard substring matches
    final directMatches = cameroonTowns.where((town) {
      final normTown = normalizeTownText(town);
      return normTown.startsWith(text) || normTown.contains(text);
    }).toList();
    if (directMatches.isNotEmpty) return directMatches;
    // If typing completely deviates, gracefully fallback to algorithmic proximity ranking
    final dynamicScored = cameroonTowns.map((town) {
      final distance = _getEditDistance(text, normalizeTownText(town));
      return MapEntry(town, distance);
    }).toList();
    dynamicScored.sort((a, b) => a.value.compareTo(b.value));
    int maxDistance = text.length <= 4 ? 1 : 2;
    return dynamicScored
        .where((entry) => entry.value <= maxDistance)
        .map((entry) => entry.key)
        .toList();
  }

  /// 7. Localization Map definitions
  static final Map<String, Map<String, String>> translations = {
    EN: {
      'landing_tagline': 'Skip the middleman. Swap directly.',
      'landing_subtitle':
          'Discover direct lease swaps, roommate matches, and safe local housing opportunities across Cameroon.',
      'landing_primary_cta': 'Browse listings',
      'landing_secondary_cta': 'Post my swap',
      'nav_feed': 'Feed',
      'nav_post': 'Post',
      'nav_match': 'Match',
      'nav_inbox': 'Inbox',
      'create_title': 'What would you like to do?',
      'create_subtitle': 'Choose your next move',
      'choice_leaving': 'I\'m leaving',
      'choice_leaving_desc': 'Post a lease transfer to an incoming tenant',
      'choice_host': 'Stay with me',
      'choice_host_desc': 'Host a roommate and split your active bills',
      'choice_looking': 'Looking for room to share',
      'choice_looking_desc': 'Post your profile so hosts can find you',
      'language_toggle': 'English / Français',
      'form_title': 'Create Your Listing',
      'form_title_label': 'Listing Title',
      'form_title_hint': 'e.g., Cozy 2-bedroom in Yaoundé',
      'form_rent_label': 'Monthly Rent',
      'form_rent_hint': 'e.g., 75000',
      'form_rent_suffix': 'CFA',
      'form_town_label': 'Town',
      'form_town_hint': 'e.g buea, bertoua, kousseri,',
      'form_quarter_label': 'Quarter',
      'form_quarter_hint': 'e.g., Quartier de l\'Indépendance',
      'form_leaving_date_label': 'I\'m leaving by',
      'form_water_label': 'Water Available',
      'form_electricity_label': 'Electricity Type',
      'form_electricity_prepaid': 'Prepaid Meter',
      'form_electricity_shared': 'Shared Meter',
      'form_kitchen_label': 'Kitchen Type',
      'form_kitchen_internal': 'Internal Kitchen',
      'form_kitchen_external': 'External Kitchen',
      'form_description_label': 'Description',
      'form_description_hint': 'Tell us more about your space...',
      'form_photos_label': 'Upload Photos (Max 3)',
      'form_photos_helper':
          'Max 3 photos. Images are automatically optimized and limited to under 1MBto save your mobile data.',
      'form_photos_count': '{count}/3 photos uploaded',
      'form_photos_error': 'Maximum 3 photos allowed',
      'form_photos_add': 'Tap to add photo',
      'form_submit': 'Post Listing',
      'form_cancel': 'Cancel',
      'looking_form_alias_label': 'Call me',
      'looking_form_alias_hint': 'Your preferred name or alias',
      'looking_form_age_label': 'Age Range',
      'looking_form_age_under20': 'Under 20',
      'looking_form_age_twenties': '20s',
      'looking_form_age_thirties': '30s',
      'looking_form_age_forties': '40s',
      'looking_form_age_over50': '50+',
      'looking_form_preferred_town': 'Preferred Town',
      'looking_form_preferred_quarter_label':
          'Preferred Quarter (Optional, open to options)',
      'looking_form_preferred_quarter_hint': 'Where would you like to stay?',
      'host_form_gender_pref_label': 'Gender Preference',
      'host_form_gender_males_only': 'Males Only',
      'host_form_gender_females_only': 'Females Only',
      'host_form_gender_open': 'Open to All',
      'host_form_target_age_label': 'Target Age Range (select all that apply)',
      'host_form_lifestyle_label': 'Lifestyle Match',
      'host_form_lifestyle_no_smoking': 'No Smoking / Non-fumeur',
      'host_form_lifestyle_no_pets': 'No Pets / Pas d\'animaux',
      'host_form_lifestyle_quiet': 'Quiet Space / Calme',
      'host_form_duration_label': 'Expected Duration',
      'host_form_duration_short': 'Short term: 1-3 months',
      'host_form_duration_medium': 'Medium term: 6 months',
      'host_form_duration_long': 'Long term: 1 year+',
      'host_form_duration_flexible': 'Flexible/Negotiable',
      'confirmation_title': 'Success!',
      'confirmation_message': 'Your listing has been posted successfully.',
      'confirmation_button': 'Back to Home',
      'feed_title': 'Available Leases',
      'feed_filter_town': 'Filter by Town',
      'feed_filter_budget': 'Max Budget',
      'feed_filter_bedrooms': 'Bedrooms',
      'feed_filter_all': 'All',
      'feed_no_results': 'No listings found. Try adjusting your filters.',
      'feed_loading': 'Loading listings...',
      'ad_safety':
          '🛡️ Keep it direct! Never wire money or send deposits before touring the apartmentin person. Read our safe swapping checklist.',
      'ad_howto':
          '💡 How a direct swap works: 1. Message the tenant. 2. Tour the space. 3. Approach thelandlord together to transfer the paperwork. Skip the agency fees entirely!',
      'ad_cleanup':
          '✨ Successfully swapped your lease? Don\'t forget to delete your listing so other swappers can focus on active apartments!',
      'gate_update_title': 'App Update Required',
      'gate_update_message':
          'A new version of KwataMan is available. Please update to continue using the app.',
      'gate_update_button': 'Update Now',
      'login_title': 'Verify Your Phone',
      'login_message':
          'Sign in to view full contact details and message other users.',
      'login_button': 'Sign In',
      'login_close': 'Later',
      'phone_masked': 'XXXXXXXXX',
      'match_title': 'Find Your Roommate',
      'match_subtitle': 'Browse profiles from verified users',
      'match_no_profiles': 'No profiles available at the moment.',
      'inbox_title': 'Messages',
      'inbox_empty': 'No messages yet. Start a conversation!',
      'detail_interest_button': "I'm Interested — Message",
      'template_message':
          'Hello, I am interested in your listing at {location}. The rent is {price}. Iwould like to discuss the lease swap and arrange a viewing. Thank you!',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'back': 'Back',
      'next': 'Next',
      'skip': 'Skip',
      'loading': 'Loading...',
      'error': 'Something went wrong',
      'success': 'Success!',
    },
    FR: {
      'landing_tagline': 'Passez l’intermédiaire. Échangez directement.',
      'landing_subtitle':
          'Découvrez les échanges directs de bail, les colocataires et les logements sécurisés à travers le Cameroun.',
      'landing_primary_cta': 'Voir les annonces',
      'landing_secondary_cta': 'Publier un échange',
      'nav_feed': 'Accueil',
      'nav_post': 'Publier',
      'nav_match': 'Colocataires',
      'nav_inbox': 'Messages',
      'create_title': 'Que voulez-vous faire ?',
      'create_subtitle': 'Choisissez votre prochaine étape',
      'choice_leaving': 'Je m\'en vais',
      'choice_leaving_desc':
          'Publiez un transfert de bail à un locataire entrant',
      'choice_host': 'Restez avec moi',
      'choice_host_desc': 'Accueillez un colocataire et partagez vos factures',
      'choice_looking': 'À la recherche d\'une chambre à partager',
      'choice_looking_desc':
          'Publiez votre profil pour que les propriétaires vous trouvent',
      'language_toggle': 'English / Français',
      'looking_form_alias_label': 'Appelez-moi',
      'looking_form_alias_hint': 'Votre nom ou surnom préféré',
      'looking_form_age_label': 'Tranche d\'âge',
      'looking_form_age_under20': '<20',
      'looking_form_age_twenties': '20s',
      'looking_form_age_thirties': '30s',
      'looking_form_age_forties': '40',
      'looking_form_age_over50': '50+',
      'looking_form_preferred_town': 'Ville préférée',
      'looking_form_preferred_quarter_label':
          'Quartier préféré (Optionnel, ouvert aux options)',
      'looking_form_preferred_quarter_hint': 'Où aimeriez-vous rester ?',
      'host_form_gender_pref_label': 'Préférence de genre',
      'host_form_gender_males_only': 'Hommes uniquement',
      'host_form_gender_females_only': 'Femmes uniquement',
      'host_form_gender_open': 'Ouvert à tous',
      'host_form_target_age_label':
          'Tranche d\'âge cible (sélectionnez tout ce qui s\'applique)',
      'host_form_lifestyle_label': 'Compatibilité de style de vie',
      'host_form_lifestyle_no_smoking': 'Non-fumeur',
      'host_form_lifestyle_no_pets': 'Pas d\'animaux',
      'host_form_lifestyle_quiet': 'Espace calme',
      'host_form_duration_label': 'Durée prévue',
      'host_form_duration_short': 'Court terme : 1-3 mois',
      'host_form_duration_medium': 'Moyen terme : 6 mois',
      'host_form_duration_long': 'Long terme : 1 an ou plus',
      'host_form_duration_flexible': 'Flexible/Négociable',
      'confirmation_title': 'Succès !',
      'confirmation_message': 'Votre annonce a été publiée avec succès.',
      'confirmation_button': 'Retour à l\'accueil',
      'form_title': 'Créer votre annonce',
      'form_title_label': 'Titre de l\'annonce',
      'form_title_hint': 'ex., Beau 2-pièces à Yaoundé',
      'form_rent_label': 'Loyer mensuel',
      'form_rent_hint': 'ex., 75000',
      'form_rent_suffix': 'CFA',
      'form_town_label': 'Ville',
      'form_town_hint': 'Ebolowa, Limbe, Garoua',
      'form_quarter_label': 'Quartier',
      'form_quarter_hint': 'ex., Quartier de l\'Indépendance',
      'form_leaving_date_label': 'Je m\'en vais le',
      'form_water_label': 'Eau disponible',
      'form_electricity_label': 'Type d\'électricité',
      'form_electricity_prepaid': 'Compteur prépayé',
      'form_electricity_shared': 'Compteur partagé',
      'form_kitchen_label': 'Type de cuisine',
      'form_kitchen_internal': 'Cuisine interne',
      'form_kitchen_external': 'Cuisine externe',
      'form_description_label': 'Description',
      'form_description_hint': 'Parlez-nous davantage de votre espace...',
      'form_photos_label': 'Télécharger des photos (Max 3)',
      'form_photos_helper':
          'Max 3 photos. Les images sont automatiquement optimisées et limitées à moins de 1 Mo pour économiser vos données mobiles.',
      'form_photos_count': '{count}/3 photos téléchargées',
      'form_photos_error': 'Maximum 3 photos autorisées',
      'form_photos_add': 'Appuyez pour ajouter une photo',
      'form_submit': 'Publier l\'annonce',
      'form_cancel': 'Annuler',
      'feed_title': 'Baux disponibles',
      'feed_filter_town': 'Filtrer par ville',
      'feed_filter_budget': 'Budget maximum',
      'feed_filter_bedrooms': 'Chambres',
      'feed_filter_all': 'Tous',
      'feed_no_results':
          'Aucune annonce trouvée. Essayez d\'ajuster vos filtres.',
      'feed_loading': 'Chargement des annonces...',
      'ad_safety':
          '🛡️ Restez direct ! Ne versez jamais d\'argent ou de dépôt avant de visiter l\'appartement en personne. Consultez notre liste de contrôle de sécurité.',
      'ad_howto':
          '💡 Comment fonctionne un échange direct : 1. Messagez le locataire. 2. Visitez l\'espace. 3. Approchez le propriétaire ensemble pour transfert des papiers. Évitez entièrement les frais d\'agence !',
      'ad_cleanup':
          '✨ Avez-vous échangé avec succès votre bail ? N\'oubliez pas de supprimer votre annonce pour que d\'autres échangeurs puissent se concentrer sur les appartements actifs !',
      'gate_update_title': 'Mise à jour requise',
      'gate_update_message':
          'Une nouvelle version de KD est disponible. Veuillez mettre à jour pour continuer à utiliser l\'application.',
      'gate_update_button': 'Mettre à jour maintenant',
      'login_title': 'Vérifiez votre téléphone',
      'login_message':
          'Connectez-vous pour afficher les coordonnées complètes et discuter avec d\'autres utilisateurs.',
      'login_button': 'Se connecter',
      'login_close': 'Plus tard',
      'phone_masked': 'XXXXXXXXX',
      'match_title': 'Trouvez votre colocataire',
      'match_subtitle': 'Parcourez les profils d\'utilisateurs vérifiés',
      'match_no_profiles': 'Aucun profil disponible pour le moment.',
      'inbox_title': 'Messages',
      'inbox_empty':
          'Aucun message pour le moment. Commencez une conversation !',
      'detail_interest_button': 'Je suis intéressé — Message',
      'template_message':
          'Bonjour, je suis intéressé(e) par votre annonce à {location}. Le loyer est de {price}. Je souhaite discuter de l’échange de bail et de la visite. Merci !',
      'yes': 'Oui',
      'no': 'Non',
      'ok': 'OK',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'back': 'Retour',
      'next': 'Suivant',
      'skip': 'Passer',
      'loading': 'Chargement...',
      'error': 'Une erreur s\'est produite',
      'success': 'Succès !',
    },
  };

  /// 8. Translation Lookup Utility Functions
  static String get(String key, {String language = EN}) {
    return translations[language]?[key] ?? key;
  }

  static String getWithParams(
    String key,
    Map<String, String> params, {
    String language = EN,
  }) {
    String value = get(key, language: language);
    params.forEach((placeholder, replacement) {
      value = value.replaceAll('{$placeholder}', replacement);
    });
    return value;
  }
}
