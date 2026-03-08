import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({Locale? initialLocale})
      : _locale = initialLocale ?? const Locale('en');

  Locale _locale;

  Locale get locale => _locale;

  void updateLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope(
      {required LocaleController controller, required Widget child})
      : super(notifier: controller, child: child);

  static LocaleController of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<LocaleScope>()
        : context.getElementForInheritedWidgetOfExactType<LocaleScope>()?.widget
            as LocaleScope?;
    if (scope == null || scope.notifier == null) {
      throw StateError('LocaleScope is missing in the widget tree.');
    }
    return scope.notifier!;
  }

  @override
  bool updateShouldNotify(LocaleScope oldWidget) =>
      notifier != oldWidget.notifier;
}
