import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:share_lelo/share_lelo.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getApkInfo returns an existing APK', (tester) async {
    final info = await ShareLelo.getApkInfo();
    expect(info.apkPath, endsWith('.apk'));
    expect(info.apkSize, greaterThan(0));
  });

  testWidgets('getApkFiles copies the APK into the cache', (tester) async {
    final files = await ShareLelo.getApkFiles(fileName: 'test_app');
    expect(files.first.path, endsWith('test_app.apk'));
    expect(files.first.existsSync(), isTrue);
    await ShareLelo.clearCache();
  });
}
