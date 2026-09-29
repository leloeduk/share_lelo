import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'share_lelo_method_channel.dart';

/// Interface commune des implémentations de share_lelo.
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

  /// Informations brutes sur l'APK installé.
  Future<Map<String, dynamic>> getApkInfo() {
    throw UnimplementedError('getApkInfo() has not been implemented.');
  }

  /// Copie l'APK dans le cache et retourne les chemins.
  Future<List<String>> prepareApk({String? fileName}) {
    throw UnimplementedError('prepareApk() has not been implemented.');
  }

  /// Copie puis partage l'APK.
  Future<List<String>> shareApk({
    String? fileName,
    String? chooserTitle,
    String? text,
    String? subject,
    String? packageName,
  }) {
    throw UnimplementedError('shareApk() has not been implemented.');
  }

  /// Supprime les copies d'APK du cache.
  Future<void> clearCache() {
    throw UnimplementedError('clearCache() has not been implemented.');
  }
}
