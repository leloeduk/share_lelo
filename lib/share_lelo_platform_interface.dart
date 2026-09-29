import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'share_lelo_method_channel.dart';

/// Common interface for share_lelo implementations.
abstract class ShareLeloPlatform extends PlatformInterface {
  /// Constructs a ShareLeloPlatform.
  ShareLeloPlatform() : super(token: _token);

  static final Object _token = Object();

  static ShareLeloPlatform _instance = MethodChannelShareLelo();

  /// The default instance of [ShareLeloPlatform] to use.
  ///
  /// Defaults to [MethodChannelShareLelo].
  static ShareLeloPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ShareLeloPlatform] when
  /// they register themselves.
  static set instance(ShareLeloPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Raw information about the installed APK.
  Future<Map<String, dynamic>> getApkInfo() {
    throw UnimplementedError('getApkInfo() has not been implemented.');
  }

  /// Copies the APK into the cache and returns the paths.
  Future<List<String>> prepareApk({String? fileName}) {
    throw UnimplementedError('prepareApk() has not been implemented.');
  }

  /// Copies then shares the APK.
  Future<List<String>> shareApk({
    String? fileName,
    String? chooserTitle,
    String? text,
    String? subject,
    String? packageName,
  }) {
    throw UnimplementedError('shareApk() has not been implemented.');
  }

  /// Deletes the cached APK copies.
  Future<void> clearCache() {
    throw UnimplementedError('clearCache() has not been implemented.');
  }
}
