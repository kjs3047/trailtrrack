import 'package:flutter_test/flutter_test.dart';
import 'package:trailtrack/features/backup/google_drive_client.dart';

void main() {
  group('GoogleDriveClient without serverClientId', () {
    test('isSignedIn returns false with a setup message, no throw', () async {
      final client = GoogleDriveClient(); // serverClientId = null
      final signed = await client.isSignedIn();
      expect(signed, isFalse);
      expect(client.lastError, isNotNull);
      expect(client.lastError, contains('Google Drive'));
      expect(client.lastError, contains('GOOGLE_DRIVE_SERVER_CLIENT_ID'));
    });

    test('signIn returns false with a setup message, no throw', () async {
      final client = GoogleDriveClient(serverClientId: '   '); // blank
      final ok = await client.signIn();
      expect(ok, isFalse);
      expect(client.lastError, contains('설정'));
    });
  });
}
