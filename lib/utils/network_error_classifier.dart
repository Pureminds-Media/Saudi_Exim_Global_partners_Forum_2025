/// Lightweight helper to detect network-style failures based on message text.
bool isNetworkErrorMessage(String? message) {
  if (message == null || message.isEmpty) return false;
  final lower = message.toLowerCase();
  return lower.contains('network error') ||
      lower.contains('dns') ||
      lower.contains('socket') ||
      lower.contains('connection') ||
      lower.contains('timeout');
}
