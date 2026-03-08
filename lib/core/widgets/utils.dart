// Utility functions ported from the React export. Add helpers here as needed.

String camelToTitle(String s) {
  final withSpaces = s.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}');
  return withSpaces.trim().replaceFirst(
    withSpaces[0],
    withSpaces[0].toUpperCase(),
  );
}
