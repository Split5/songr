import '../../api/subsonic_api.dart';

Uri? parseRadioStreamUri(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || uri.host.isEmpty || uri.userInfo.isNotEmpty) return null;
  if (uri.scheme == 'https') return uri;
  if (uri.scheme == 'http' && SubsonicApi.isPrivateHost(uri.host)) return uri;
  return null;
}
