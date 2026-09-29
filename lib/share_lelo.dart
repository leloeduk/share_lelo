/// Partage le fichier APK complet de votre application Flutter (Android).
///
/// ```dart
/// await ShareLelo.shareApk();
/// ```
library;

import 'dart:io';

import 'share_lelo_platform_interface.dart';

/// Informations sur l'APK de l'application installée.
class ApkInfo {
  /// Crée un [ApkInfo]. Utilisez plutôt [ShareLelo.getApkInfo].
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

  /// Construit un [ApkInfo] à partir de la réponse du code natif.
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

  /// Nom affiché de l'application.
  final String appName;

  /// Identifiant Android, ex. `com.exemple.monapp`.
  final String packageName;

  /// Version lisible, ex. `1.2.0`.
  final String versionName;

  /// Numéro de build.
  final int versionCode;

  /// Chemin de l'APK principal (base.apk) installé sur l'appareil.
  final String apkPath;

  /// Taille de l'APK principal en octets.
  final int apkSize;

  /// APK "split" présents si l'app a été installée depuis un App Bundle
  /// (Play Store). Vide pour un APK classique (`flutter build apk`).
  final List<String> splitApkPaths;

  /// Taille totale (APK principal + splits) en octets.
  final int totalSize;

  /// `true` si l'app est découpée en plusieurs APK. Dans ce cas l'APK
  /// principal seul ne suffit pas pour installer l'app sur un autre appareil.
  bool get isSplit => splitApkPaths.isNotEmpty;

  /// Taille totale lisible, ex. `18.4 Mo`.
  String get formattedSize {
    const units = ['o', 'Ko', 'Mo', 'Go'];
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

/// Point d'entrée du package.
class ShareLelo {
  ShareLelo._();

  static ShareLeloPlatform get _platform => ShareLeloPlatform.instance;

  static void _ensureAndroid() {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'share_lelo ne fonctionne que sur Android (les APK sont propres à Android).',
      );
    }
  }

  /// Ouvre la feuille de partage Android avec le fichier APK complet de
  /// l'application (Bluetooth, WhatsApp, Gmail, Drive, Nearby Share...).
  ///
  /// - [fileName] : nom du fichier partagé (par défaut `NomApp_vX.Y.Z.apk`).
  /// - [chooserTitle] : titre de la feuille de partage.
  /// - [text] / [subject] : message accompagnant le fichier.
  /// - [packageName] : envoie directement à une app précise sans sélecteur,
  ///   ex. `com.whatsapp` ou `com.android.bluetooth`.
  ///
  /// Retourne les chemins des fichiers partagés.
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

  /// Récupère les informations de l'APK installé (taille, version, chemin...).
  static Future<ApkInfo> getApkInfo() async {
    _ensureAndroid();
    return ApkInfo.fromMap(await _platform.getApkInfo());
  }

  /// Copie l'APK dans le cache de l'application et retourne les fichiers,
  /// sans ouvrir le partage. Utile pour un envoi personnalisé (upload, etc.).
  static Future<List<File>> getApkFiles({String? fileName}) async {
    _ensureAndroid();
    final paths = await _platform.prepareApk(fileName: fileName);
    return paths.map(File.new).toList();
  }

  /// Supprime les copies d'APK du cache pour libérer de l'espace.
  static Future<void> clearCache() {
    _ensureAndroid();
    return _platform.clearCache();
  }
}
