import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/app/v2/v2_catalog_scope.dart';

void main() {
  const url = 'https://musik.example';
  final scope = catalogAccountScope(url, 'listener');

  test('catalog scope is safe to persist on iOS', () {
    expect(scope, '$url|listener');
    expect(scope, isNot(contains('\u0000')));
  });

  test('the truncated legacy scope keeps the current cache', () {
    expect(
      shouldClearCatalogCache(
        storedScope: url,
        url: url,
        currentScope: scope,
        sameSessionAccountChanged: false,
      ),
      isFalse,
    );
  });

  test('a different persisted account clears the cache', () {
    expect(
      shouldClearCatalogCache(
        storedScope: catalogAccountScope(url, 'someone-else'),
        url: url,
        currentScope: scope,
        sameSessionAccountChanged: false,
      ),
      isTrue,
    );
  });
}
