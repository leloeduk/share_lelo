import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'share_lelo_platform_interface.dart';

/// An implementation of [ShareLeloPlatform] that uses method channels.
class MethodChannelShareLelo extends ShareLeloPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('share_lelo');

  @override
  Future<Map<String, dynamic>> getApkInfo() async {
    final info = await methodChannel.invokeMapMethod<String, dynamic>(
      'getApkInfo',
    );
    return info ?? const {};
  }

  @override
  Future<List<String>> prepareApk({String? fileName}) async {
    final paths = await methodChannel.invokeListMethod<String>('prepareApk', {
      'fileName': fileName,
    });
    return paths ?? const [];
  }

  @override
  Future<List<String>> shareApk({
    String? fileName,
    String? chooserTitle,
    String? text,
    String? subject,
    String? packageName,
  }) async {
    final paths = await methodChannel.invokeListMethod<String>('shareApk', {
      'fileName': fileName,
      'chooserTitle': chooserTitle,
      'text': text,
      'subject': subject,
      'packageName': packageName,
    });
    return paths ?? const [];
  }

  @override
  Future<void> clearCache() => methodChannel.invokeMethod<void>('clearCache');
}
