String catalogAccountScope(String url, String username) => '$url|$username';

String normalizeStoredCatalogScope({
  required String? stored,
  required String url,
  required String currentScope,
}) => stored == url ? currentScope : stored ?? '';

bool shouldClearCatalogCache({
  required String? storedScope,
  required String url,
  required String currentScope,
  required bool sameSessionAccountChanged,
}) {
  final normalized = normalizeStoredCatalogScope(
    stored: storedScope,
    url: url,
    currentScope: currentScope,
  );
  return (normalized.isNotEmpty && normalized != currentScope) ||
      sameSessionAccountChanged;
}
