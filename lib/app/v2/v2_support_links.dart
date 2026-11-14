abstract final class V2SupportLinks {
  static const supportEmail = 'support@simonbystrom.se';
  static const supportPageVisible = false;
  static const refundLinkVisible = false;
  static final website = Uri.https('simonbystrom.se', '/');
  static final appPage = Uri.https('simonbystrom.se', '/soengr/');
  static final privacy = Uri.https('simonbystrom.se', '/privacy/');
  static final refunds = Uri.https('reportaproblem.apple.com', '/');
  static final remoteSetup = Uri.parse(
    'https://simonbystrom.se/soengr/#remote',
  );
  static final smartSetup = Uri.parse('https://simonbystrom.se/soengr/#smart');
  static final lyricsSetup = Uri.parse(
    'https://simonbystrom.se/soengr/#lyrics',
  );
  static final securitySetup = Uri.parse(
    'https://simonbystrom.se/soengr/#security',
  );

  static Uri mail({required String subject, required String body}) => Uri(
    scheme: 'mailto',
    path: supportEmail,
    queryParameters: {'subject': subject, 'body': body},
  );
}
