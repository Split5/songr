String sanitizeDiagnosticText(String value) => value
    .replaceAll(RegExp(r'https?://[^\s]+', caseSensitive: false), '[url]')
    .replaceAllMapped(
      RegExp(
        r'(password|token|secret|authorization)[=:]\s*\S+',
        caseSensitive: false,
      ),
      (match) => '${match[1]}=[redacted]',
    )
    .replaceAll(
      RegExp(r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}', caseSensitive: false),
      '[email]',
    )
    .trim();
