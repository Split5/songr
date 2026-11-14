import 'package:flutter_test/flutter_test.dart';
import 'package:navimusic/domain/playback/radio_stream_uri.dart';

void main() {
  test('allows public HTTPS radio streams', () {
    expect(
      parseRadioStreamUri('https://radio.example/live.mp3')?.host,
      'radio.example',
    );
    expect(
      parseRadioStreamUri('https://radio.example/live.m3u8')?.path,
      '/live.m3u8',
    );
  });

  test('allows cleartext only for intended private hosts', () {
    expect(
      parseRadioStreamUri('http://192.168.0.50:8000/radio')?.host,
      '192.168.0.50',
    );
    expect(parseRadioStreamUri('http://radio.example/live'), isNull);
  });

  test('rejects local files, credentials, and unknown schemes', () {
    expect(parseRadioStreamUri('file:///Users/simon/private.mp3'), isNull);
    expect(parseRadioStreamUri('content://media/song/1'), isNull);
    expect(parseRadioStreamUri('javascript:alert(1)'), isNull);
    expect(
      parseRadioStreamUri('https://user:secret@radio.example/live'),
      isNull,
    );
    expect(parseRadioStreamUri('not a url'), isNull);
  });
}
