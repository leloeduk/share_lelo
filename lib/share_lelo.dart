/// Share the full APK file of your Flutter app (Android).
///
/// ```dart
/// await ShareLelo.shareApk();
/// ```
library;

import 'dart:io';

import 'share_lelo_platform_interface.dart';

/// Information about the installed app's APK.
class ApkInfo {
  /// Creates an [ApkInfo]. Prefer [ShareLelo.getApkInfo].
  const ApkInfo({
    required this.appName,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.apkPath,
    required this.apkSize,
    required this.splitApkPaths,
    required this.totalSize,
  });

  /// Builds an [ApkInfo] from the native response.
  factory ApkInfo.fromMap(Map<String, dynamic> map) => ApkInfo(
    appName: map['appName'] as String? ?? '',
    packageName: map['packageName'] as String? ?? '',
    versionName: map['versionName'] as String? ?? '',
    versionCode: (map['versionCode'] as num?)?.toInt() ?? 0,
    apkPath: map['apkPath'] as String? ?? '',
    apkSize: (map['apkSize'] as num?)?.toInt() ?? 0,
    splitApkPaths: List<String>.from(map['splitApkPaths'] as List? ?? const []),
    totalSize: (map['totalSize'] as num?)?.toInt() ?? 0,
  );

  /// Display name of the app.
  final String appName;

  /// Android application ID, e.g. `com.example.myapp`.
  final String packageName;

  /// Human-readable version, e.g. `1.2.0`.
  final String versionName;

  /// Build number.
  final int versionCode;

  /// Path of the main APK (base.apk) installed on the device.
  final String apkPath;

  /// Size of the main APK in bytes.
  final int apkSize;

  /// Split APKs present when the app was installed from an App Bundle
  /// (Play Store). Empty for a regular APK (`flutter build apk`).
  final List<String> splitApkPaths;

  /// Total size (main APK + splits) in bytes.
  final int totalSize;

  /// `true` when the app is split into several APKs. In that case the main
  /// APK alone is not enough to install the app on another device.
  bool get isSplit => splitApkPaths.isNotEmpty;

  /// Human-readable total size, e.g. `18.4 MB`.
  String get formattedSize {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = totalSize.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    return '${size.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
  }

  @override
  String toString() =>
      'ApkInfo($appName $versionName+$versionCode, $formattedSize, split: $isSplit)';
}

/// Entry point of the package.
class ShareLelo {
  ShareLelo._();

  static ShareLeloPlatform get _platform => ShareLeloPlatform.instance;

  static void _ensureAndroid() {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'share_lelo only works on Android (APKs are Android-specific).',
      );
    }
  }

  /// Opens the Android share sheet with the app's full APK file
  /// (Bluetooth, WhatsApp, Gmail, Drive, Nearby Share...).
  ///
  /// - [fileName]: name of the shared file (default `AppName_vX.Y.Z.apk`).
  /// - [chooserTitle]: title of the share sheet.
  /// - [text] / [subject]: message sent along with the file.
  /// - [packageName]: sends directly to a specific app without the chooser,
  ///   e.g. `com.whatsapp` or `com.android.bluetooth`.
  ///
  /// Returns the paths of the shared files.
  static Future<List<String>> shareApk({
    String? fileName,
    String? chooserTitle,
    String? text,
    String? subject,
    String? packageName,
  }) {
    _ensureAndroid();
    return _platform.shareApk(
      fileName: fileName,
      chooserTitle: chooserTitle,
      text: text,
      subject: subject,
      packageName: packageName,
    );
  }

  /// Returns information about the installed APK (size, version, path...).
  static Future<ApkInfo> getApkInfo() async {
    _ensureAndroid();
    return ApkInfo.fromMap(await _platform.getApkInfo());
  }

  /// Copies the APK into the app cache and returns the files without opening
  /// the share sheet. Useful for custom delivery (upload, etc.).
  static Future<List<File>> getApkFiles({String? fileName}) async {
    _ensureAndroid();
    final paths = await _platform.prepareApk(fileName: fileName);
    return paths.map(File.new).toList();
  }

  /// Deletes the cached APK copies to free up space.
  static Future<void> clearCache() {
    _ensureAndroid();
    return _platform.clearCache();
  }
}
