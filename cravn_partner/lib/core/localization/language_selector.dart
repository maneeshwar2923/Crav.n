import 'package:flutter/material.dart';

import 'app_localizations.dart';
import 'locale_scope.dart';

Future<void> showLanguageSelector(BuildContext context) async {
  final controller = LocaleScope.of(context, listen: false);
  final loc = context.loc;
  final current = controller.locale;

  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.languageSheetTitle(),
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.languageSheetSubtitle(),
                    style: Theme.of(sheetContext)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: const Color(0xFF5C7470)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...AppLocalizations.supportedLocales.map((locale) {
              final selected = locale.languageCode == current.languageCode;
              return ListTile(
                leading: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: const Color(0xFF006D3B),
                ),
                title: Text(loc.languageName(locale)),
                onTap: () {
                  controller.updateLocale(locale);
                  Navigator.of(sheetContext).pop();
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return IconButton(
      tooltip: loc.languageButtonTooltip(),
      icon: const Icon(Icons.language, color: Color(0xFF1B4332)),
      onPressed: () => showLanguageSelector(context),
    );
  }
}
