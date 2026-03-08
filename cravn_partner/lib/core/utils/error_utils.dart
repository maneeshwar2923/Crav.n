import 'dart:io';

String resolveDisplayError(Object error, {String? fallback}) {
  const offlineMessage = 'Please connect to the internet.';

  if (error is SocketException) {
    return offlineMessage;
  }

  final text = error.toString();
  if (_looksLikeNetworkIssue(text)) {
    return offlineMessage;
  }

  return fallback ?? text;
}

bool _looksLikeNetworkIssue(String message) {
  final lower = message.toLowerCase();
  return lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection refused') ||
      lower.contains('internet connection appears to be offline') ||
      lower.contains('timed out');
}
