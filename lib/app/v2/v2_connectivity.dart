import 'package:connectivity_plus/connectivity_plus.dart';

bool hasNetwork(Iterable<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);

bool shouldResumeSync({
  required bool wasOnline,
  required Iterable<ConnectivityResult> results,
}) => !wasOnline && hasNetwork(results);
