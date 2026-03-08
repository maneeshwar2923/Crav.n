import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralised app configuration helpers.
class AppConfig {
  static const String _mapsKeyDefine =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');

  static String get googleMapsApiKey {
    if (_mapsKeyDefine.isNotEmpty) {
      return _mapsKeyDefine;
    }
    try {
      return dotenv.maybeGet('GOOGLE_MAPS_API_KEY') ?? '';
    } catch (_) {
      return '';
    }
  }

  static bool get hasGoogleMapsApiKey => googleMapsApiKey.isNotEmpty;
}
