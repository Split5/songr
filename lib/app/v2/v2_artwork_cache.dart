String coverArtCacheKey({
  required String accountScope,
  required String coverArt,
  required int size,
}) =>
    '${Uri.encodeComponent(accountScope)}|'
    '${Uri.encodeComponent(coverArt)}|$size';
