# share_lelo

Partagez **le fichier APK complet** de votre application Flutter — pas un lien, l'application elle-même — via Bluetooth, WhatsApp, Telegram, Gmail, Drive, Nearby Share, etc.

`share_plus` partage du texte ou des fichiers que vous fournissez ; `share_lelo` récupère lui-même l'APK installé sur le téléphone et l'envoie, en **une ligne**.

> Android uniquement (les APK n'existent que sur Android).

## Installation

```yaml
dependencies:
  share_lelo: ^0.1.0
```

**Aucune configuration nécessaire** : pas de permission, pas de `FileProvider` à déclarer, rien à modifier dans `AndroidManifest.xml`. Le plugin s'en occupe.

## Utilisation

```dart
import 'package:share_lelo/share_lelo.dart';

ElevatedButton(
  onPressed: () => ShareLelo.shareApk(),
  child: const Text("Partager l'application"),
);
```

### Options

```dart
await ShareLelo.shareApk(
  fileName: 'MonApp',                  // → MonApp.apk (défaut : NomApp_v1.0.0.apk)
  chooserTitle: 'Envoyer via…',
  text: 'Installe mon application !',
  subject: 'MonApp',
  packageName: 'com.whatsapp',         // optionnel : ouvre directement WhatsApp
);
```

Quelques `packageName` utiles : `com.android.bluetooth`, `com.whatsapp`, `org.telegram.messenger`, `com.google.android.gm`.

### Informations sur l'APK

```dart
final info = await ShareLelo.getApkInfo();
print(info.appName);        // Mon App
print(info.versionName);    // 1.0.0
print(info.formattedSize);  // 18.4 Mo
print(info.isSplit);        // false
```

### Récupérer le fichier sans partager

```dart
final files = await ShareLelo.getApkFiles(fileName: 'MonApp');
// files.first → File('/data/user/0/…/cache/share_lelo/MonApp.apk')
// upload vers un serveur, etc.

await ShareLelo.clearCache(); // libère l'espace ensuite
```

## ⚠️ Important : APK universel vs App Bundle

| Installation de l'app | Résultat du partage |
|---|---|
| `flutter build apk` (APK universel), APK installé à la main | ✅ Un seul `.apk`, installable directement sur n'importe quel Android |
| Play Store / `flutter build appbundle` | ⚠️ L'app est découpée en plusieurs APK (`info.isSplit == true`). Tous les fichiers sont envoyés, mais le destinataire doit les installer ensemble (ex. avec l'app *SAI*) |

Pour une app destinée au partage hors-store, construisez avec `flutter build apk --release`.

Côté destinataire : Android demandera d'autoriser l'installation depuis « sources inconnues » pour l'application qui a reçu le fichier (Fichiers, WhatsApp…). C'est normal.

## Fonctionnement

1. Le plugin lit le chemin de l'APK installé (`ApplicationInfo.sourceDir` + `splitSourceDirs`).
2. Il le copie dans `cache/share_lelo/` avec un nom lisible (en arrière-plan, sans bloquer l'UI).
3. Il l'expose via son propre `FileProvider` (autorité `<votre.package>.share_lelo.fileprovider`, sans conflit avec d'autres plugins) et ouvre la feuille de partage Android avec le type `application/vnd.android.package-archive`.

## Licence

Voir [LICENSE](LICENSE).
