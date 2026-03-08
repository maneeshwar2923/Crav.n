import 'package:flutter/material.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_scope.dart';
import 'features/auth/auth_gate.dart';
import 'core/theme/theme.dart';

class CravnPartnerApp extends StatefulWidget {
  const CravnPartnerApp({super.key});

  @override
  State<CravnPartnerApp> createState() => _CravnPartnerAppState();
}

class _CravnPartnerAppState extends State<CravnPartnerApp> {
  late final LocaleController _localeController;

  @override
  void initState() {
    super.initState();
    _localeController = LocaleController(initialLocale: const Locale('en'));
  }

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return LocaleScope(
      controller: _localeController,
      child: AnimatedBuilder(
        animation: _localeController,
        builder: (context, _) {
          return MaterialApp(
            title: "Crav'n Partner",
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: LocalizationDelegates.delegates,
            locale: _localeController.locale,
            theme: buildCravnPartnerTheme(),
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
