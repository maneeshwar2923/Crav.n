import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('hi')];

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'nav.dashboard': 'Dashboard',
      'nav.map': 'Map',
      'nav.orders': 'Orders',
      'nav.profile': 'Profile',
      'language.buttonTooltip': 'Change language',
      'language.sheetTitle': 'Choose your language',
      'language.sheetSubtitle': 'Switch between available languages instantly.',
      'language.english': 'English',
      'language.hindi': 'Hindi',
      'dashboard.refresh': 'Refresh',
      'dashboard.signOut': 'Sign out',
      'dashboard.retry': 'Retry',
      'dashboard.tryAgain': 'Try again',
      'dashboard.errorMissingProfile':
          'We could not load your host profile just yet. Pull to refresh or try again later.',
      'dashboard.featureComingSoon':
          '{feature} is almost ready. We are polishing these partner tools right now.',
      'dashboard.contactSupportMessage':
          'Need anything? Email onboarding@cravn.app and the team will help right away.',
      'dashboard.statusLabel': 'Status: {status}',
      'dashboard.welcomeBack': 'Welcome back, {name}',
      'dashboard.keepRescuing':
          'Keep rescuing meals! Your listings have served {portions} portions so far.',
      'dashboard.highlights': 'Highlights',
      'dashboard.topListing': 'Top listing',
      'dashboard.recentActivity': 'Recent activity',
      'dashboard.ordersSection': 'Recent orders',
      'dashboard.ordersEmpty':
          'No orders yet. Share your rescue bundles with nearby diners.',
      'dashboard.safetySection': 'Food safety center',
      'dashboard.safetyEmpty':
          'Upload your first food safety checklist to earn verified badges.',
      'dashboard.ordersPlaceholder': 'Orders you complete will show here.',
      'dashboard.pendingSafety':
          'You have {count} checklist(s) awaiting review.',
      'dashboard.quick.createListing': 'Create listing',
      'dashboard.quick.manageOrders': 'Manage orders',
      'dashboard.quick.foodSafety': 'Food safety center',
      'dashboard.quick.contactSupport': 'Contact support',
      'dashboard.metric.totalOrders': 'Total orders',
      'dashboard.metric.portionsRescued': 'Portions rescued',
      'dashboard.metric.foodSaved': 'Food saved',
      'dashboard.metric.grossRevenue': 'Gross revenue',
      'dashboard.metric.averageRating': 'Average rating',
      'dashboard.metric.pendingSafetyChecks': 'Safety checks pending',
      'dashboard.profile.verificationComplete': 'Verification complete',
      'dashboard.profile.verificationPending': 'Verification pending',
      'dashboard.profile.latestVerification': 'Latest verification update',
      'dashboard.profile.submitted': 'Submitted: {value}',
      'dashboard.profile.reviewed': 'Reviewed: {value}',
      'dashboard.button.signOut': 'Sign out',
      'dashboard.button.close': 'Close',
      'dashboard.map.enableTitle': 'Enable maps to view nearby listings',
      'dashboard.map.enableMessage':
          'Add your Google Maps API key (com.google.android.geo.API_KEY) inside AndroidManifest.xml to unlock the live partner map.',
      'dashboard.map.noListings':
          'Add your first listing to see it on the map.',
      'dashboard.map.portionsAvailable': '{count} portions available',
      'dashboard.map.portionsSoon': 'Portions coming soon',
      'dashboard.listing.price.free': 'Free',
      'dashboard.listing.status.verified': 'VERIFIED',
      'dashboard.listing.status.pending': 'PENDING',
      'common.language': 'Language',
      'common.status': 'Status',
    },
    'hi': {
      'nav.dashboard': 'डैशबोर्ड',
      'nav.map': 'मानचित्र',
      'nav.orders': 'ऑर्डर',
      'nav.profile': 'प्रोफ़ाइल',
      'language.buttonTooltip': 'भाषा बदलें',
      'language.sheetTitle': 'अपनी भाषा चुनें',
      'language.sheetSubtitle': 'उपलब्ध भाषाओं के बीच तुरंत स्विच करें।',
      'language.english': 'अंग्रेज़ी',
      'language.hindi': 'हिन्दी',
      'dashboard.refresh': 'रिफ्रेश',
      'dashboard.signOut': 'साइन आउट',
      'dashboard.retry': 'पुनः प्रयास करें',
      'dashboard.tryAgain': 'फिर से प्रयास करें',
      'dashboard.errorMissingProfile':
          'हम अभी आपका होस्ट प्रोफ़ाइल लोड नहीं कर सके। रिफ्रेश करें या बाद में पुनः प्रयास करें।',
      'dashboard.featureComingSoon':
          '{feature} लगभग तैयार है। हम पार्टनर टूल्स को अंतिम रूप दे रहे हैं।',
      'dashboard.contactSupportMessage':
          'मदद चाहिए? onboarding@cravn.app पर ईमेल भेजें, टीम तुरंत सहायता करेगी।',
      'dashboard.statusLabel': 'स्थिति: {status}',
      'dashboard.welcomeBack': 'वापसी पर स्वागत है, {name}',
      'dashboard.keepRescuing':
          'भोजन बचाते रहें! आपकी लिस्टिंग ने अब तक {portions} हिस्से परोसे हैं।',
      'dashboard.highlights': 'मुख्य बातें',
      'dashboard.topListing': 'सर्वश्रेष्ठ लिस्टिंग',
      'dashboard.recentActivity': 'हाल की गतिविधि',
      'dashboard.ordersSection': 'हाल के ऑर्डर',
      'dashboard.ordersEmpty':
          'अभी कोई ऑर्डर नहीं है। अपने रेस्क्यू बंडल पास के भोजनकर्ताओं के साथ साझा करें।',
      'dashboard.safetySection': 'खाद्य सुरक्षा केंद्र',
      'dashboard.safetyEmpty':
          'वेरिफाइड बैज पाने के लिए अपनी पहली खाद्य सुरक्षा चेकलिस्ट अपलोड करें।',
      'dashboard.ordersPlaceholder':
          'आपके पूर्ण किए गए ऑर्डर यहाँ दिखाई देंगे।',
      'dashboard.pendingSafety':
          'आपके पास {count} चेकलिस्ट समीक्षा के लिए प्रतीक्षा कर रही हैं।',
      'dashboard.quick.createListing': 'नई लिस्टिंग बनाएँ',
      'dashboard.quick.manageOrders': 'ऑर्डर प्रबंधित करें',
      'dashboard.quick.foodSafety': 'खाद्य सुरक्षा केंद्र',
      'dashboard.quick.contactSupport': 'सहायता से संपर्क करें',
      'dashboard.metric.totalOrders': 'कुल ऑर्डर',
      'dashboard.metric.portionsRescued': 'बचाए गए हिस्से',
      'dashboard.metric.foodSaved': 'बचाया हुआ भोजन',
      'dashboard.metric.grossRevenue': 'कुल राजस्व',
      'dashboard.metric.averageRating': 'औसत रेटिंग',
      'dashboard.metric.pendingSafetyChecks': 'सुरक्षा जांच लंबित',
      'dashboard.profile.verificationComplete': 'सत्यापन पूरा',
      'dashboard.profile.verificationPending': 'सत्यापन लंबित',
      'dashboard.profile.latestVerification': 'ताज़ा सत्यापन अपडेट',
      'dashboard.profile.submitted': 'जमा किया गया: {value}',
      'dashboard.profile.reviewed': 'समीक्षा की गई: {value}',
      'dashboard.button.signOut': 'साइन आउट',
      'dashboard.button.close': 'बंद करें',
      'dashboard.map.enableTitle':
          'मानचित्र देखने के लिए Google Maps सक्षम करें',
      'dashboard.map.enableMessage':
          'लाइव पार्टनर मानचित्र देखने के लिए AndroidManifest.xml में Google Maps API कुंजी (com.google.android.geo.API_KEY) जोड़ें।',
      'dashboard.map.noListings':
          'मानचित्र पर देखने के लिए अपनी पहली लिस्टिंग जोड़ें।',
      'dashboard.map.portionsAvailable': '{count} हिस्से उपलब्ध',
      'dashboard.map.portionsSoon': 'हिस्से शीघ्र आ रहे हैं',
      'dashboard.listing.price.free': 'निःशुल्क',
      'dashboard.listing.status.verified': 'सत्यापित',
      'dashboard.listing.status.pending': 'लंबित',
      'common.language': 'भाषा',
      'common.status': 'स्थिति',
    },
  };

  String _format(String key, [Map<String, String>? params]) {
    final fallbackValues = _localizedValues[_fallbackLocale]!;
    final values = _localizedValues[locale.languageCode] ?? fallbackValues;
    final template = values[key] ?? fallbackValues[key] ?? key;
    if (params == null || params.isEmpty) {
      return template;
    }
    return params.entries.fold(
      template,
      (acc, entry) => acc.replaceAll('{${entry.key}}', entry.value),
    );
  }

  static const _fallbackLocale = 'en';

  String navDashboard() => _format('nav.dashboard');
  String navMap() => _format('nav.map');
  String navOrders() => _format('nav.orders');
  String navProfile() => _format('nav.profile');
  String languageButtonTooltip() => _format('language.buttonTooltip');
  String languageSheetTitle() => _format('language.sheetTitle');
  String languageSheetSubtitle() => _format('language.sheetSubtitle');
  String languageName(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return _format('language.hindi');
      case 'en':
      default:
        return _format('language.english');
    }
  }

  String dashboardRefresh() => _format('dashboard.refresh');
  String dashboardSignOut() => _format('dashboard.signOut');
  String dashboardRetry() => _format('dashboard.retry');
  String dashboardTryAgain() => _format('dashboard.tryAgain');
  String dashboardErrorMissingProfile() =>
      _format('dashboard.errorMissingProfile');
  String dashboardFeatureComingSoon(String feature) =>
      _format('dashboard.featureComingSoon', {'feature': feature});
  String dashboardContactSupportMessage() =>
      _format('dashboard.contactSupportMessage');
  String dashboardStatusLabel(String status) =>
      _format('dashboard.statusLabel', {'status': status});
  String dashboardWelcomeBack(String name) =>
      _format('dashboard.welcomeBack', {'name': name});
  String dashboardKeepRescuing(String portions) =>
      _format('dashboard.keepRescuing', {'portions': portions});
  String dashboardHighlights() => _format('dashboard.highlights');
  String dashboardTopListing() => _format('dashboard.topListing');
  String dashboardRecentActivity() => _format('dashboard.recentActivity');
  String dashboardOrdersSection() => _format('dashboard.ordersSection');
  String dashboardOrdersEmpty() => _format('dashboard.ordersEmpty');
  String dashboardSafetySection() => _format('dashboard.safetySection');
  String dashboardSafetyEmpty() => _format('dashboard.safetyEmpty');
  String dashboardOrdersPlaceholder() => _format('dashboard.ordersPlaceholder');
  String dashboardPendingSafety(int count) =>
      _format('dashboard.pendingSafety', {'count': '$count'});
  String dashboardQuickCreateListing() =>
      _format('dashboard.quick.createListing');
  String dashboardQuickManageOrders() =>
      _format('dashboard.quick.manageOrders');
  String dashboardQuickFoodSafety() => _format('dashboard.quick.foodSafety');
  String dashboardQuickContactSupport() =>
      _format('dashboard.quick.contactSupport');
  String metricTotalOrders() => _format('dashboard.metric.totalOrders');
  String metricPortionsRescued() => _format('dashboard.metric.portionsRescued');
  String metricFoodSaved() => _format('dashboard.metric.foodSaved');
  String metricGrossRevenue() => _format('dashboard.metric.grossRevenue');
  String metricAverageRating() => _format('dashboard.metric.averageRating');
  String metricPendingSafetyChecks() =>
      _format('dashboard.metric.pendingSafetyChecks');
  String profileVerificationComplete() =>
      _format('dashboard.profile.verificationComplete');
  String profileVerificationPending() =>
      _format('dashboard.profile.verificationPending');
  String profileLatestVerification() =>
      _format('dashboard.profile.latestVerification');
  String profileSubmitted(String value) =>
      _format('dashboard.profile.submitted', {'value': value});
  String profileReviewed(String value) =>
      _format('dashboard.profile.reviewed', {'value': value});
  String buttonSignOut() => _format('dashboard.button.signOut');
  String buttonClose() => _format('dashboard.button.close');
  String mapEnableTitle() => _format('dashboard.map.enableTitle');
  String mapEnableMessage() => _format('dashboard.map.enableMessage');
  String mapNoListings() => _format('dashboard.map.noListings');
  String mapPortionsAvailable(int count) =>
      _format('dashboard.map.portionsAvailable', {'count': '$count'});
  String mapPortionsSoon() => _format('dashboard.map.portionsSoon');
  String listingPriceFree() => _format('dashboard.listing.price.free');
  String listingStatusVerified() =>
      _format('dashboard.listing.status.verified');
  String listingStatusPending() => _format('dashboard.listing.status.pending');
  String commonStatus() => _format('common.status');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((supported) => supported.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get loc =>
      Localizations.of<AppLocalizations>(
        this,
        AppLocalizations,
      ) ??
      AppLocalizations(const Locale('en'));
}

class LocalizationDelegates {
  static const delegates = <LocalizationsDelegate<dynamic>>[
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
