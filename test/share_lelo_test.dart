import 'package:flutter_test/flutter_test.dart';
import 'package:share_lelo/share_lelo.dart';
import 'package:share_lelo/share_lelo_method_channel.dart';
import 'package:share_lelo/share_lelo_platform_interface.dart';

void main() {
  test('$MethodChannelShareLelo est l\'instance par défaut', () {
    expect(ShareLeloPlatform.instance, isInstanceOf<MethodChannelShareLelo>());
  });

  test('ApkInfo.fromMap', () {
    final info = ApkInfo.fromMap({
      'appName': 'Demo',
      'packageName': 'com.demo',
      'versionName': '1.2.0',
      'versionCode': 3,
      'apkPath': '/data/app/base.apk',
      'apkSize': 19293798,
      'splitApkPaths': ['/data/app/split_config.arm64_v8a.apk'],
      'totalSize': 19293798,
    });
    expect(info.appName, 'Demo');
    expect(info.versionCode, 3);
    expect(info.isSplit, isTrue);
    expect(info.formattedSize, '18.4 Mo');
  });

  test('ApkInfo sans splits', () {
    final info = ApkInfo.fromMap({'totalSize': 512});
    expect(info.isSplit, isFalse);
    expect(info.formattedSize, '512 o');
  });
}
