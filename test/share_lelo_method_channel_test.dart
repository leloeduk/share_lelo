import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_lelo/share_lelo_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelShareLelo();
  const channel = MethodChannel('share_lelo');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'getApkInfo':
              return {'appName': 'Demo', 'apkSize': 42};
            case 'prepareApk':
            case 'shareApk':
              return ['/cache/share_lelo/Demo_v1.0.0.apk'];
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getApkInfo', () async {
    expect(await platform.getApkInfo(), {'appName': 'Demo', 'apkSize': 42});
  });

  test('shareApk envoie les arguments', () async {
    final paths = await platform.shareApk(
      fileName: 'MonApp',
      text: 'Installe mon app',
      packageName: 'com.whatsapp',
    );
    expect(paths, ['/cache/share_lelo/Demo_v1.0.0.apk']);
    expect(calls.single.method, 'shareApk');
    expect(calls.single.arguments, {
      'fileName': 'MonApp',
      'chooserTitle': null,
      'text': 'Installe mon app',
      'subject': null,
      'packageName': 'com.whatsapp',
    });
  });

  test('prepareApk', () async {
    expect(await platform.prepareApk(), hasLength(1));
  });
}
