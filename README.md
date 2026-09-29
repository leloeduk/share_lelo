# share_lelo

Share **the full APK file** of your Flutter app — not a link, the app itself — via Bluetooth, WhatsApp, Telegram, Gmail, Drive, Nearby Share and more.

`share_plus` shares text or files you provide; `share_lelo` finds the APK installed on the phone and sends it for you, in **one line**.

> Android only (APKs only exist on Android).

## Installation

```yaml
dependencies:
  share_lelo: ^0.1.1
```

**No setup required**: no permissions, no `FileProvider` to declare, nothing to change in `AndroidManifest.xml`. The plugin handles it.

## Usage

```dart
import 'package:share_lelo/share_lelo.dart';

ElevatedButton(
  onPressed: () => ShareLelo.shareApk(),
  child: const Text('Share app'),
);
```

### Options

```dart
await ShareLelo.shareApk(
  fileName: 'MyApp',                   // → MyApp.apk (default: AppName_v1.0.0.apk)
  chooserTitle: 'Send via…',
  text: 'Install my app!',
  subject: 'MyApp',
  packageName: 'com.whatsapp',         // optional: opens WhatsApp directly
);
```

Useful `packageName` values: `com.android.bluetooth`, `com.whatsapp`, `org.telegram.messenger`, `com.google.android.gm`.

### APK information

```dart
final info = await ShareLelo.getApkInfo();
print(info.appName);        // My App
print(info.versionName);    // 1.0.0
print(info.formattedSize);  // 18.4 MB
print(info.isSplit);        // false
```

### Get the file without sharing

```dart
final files = await ShareLelo.getApkFiles(fileName: 'MyApp');
// files.first → File('/data/user/0/…/cache/share_lelo/MyApp.apk')
// upload it to a server, etc.

await ShareLelo.clearCache(); // free up space afterwards
```

## ⚠️ Important: universal APK vs App Bundle

| How the app was installed | Sharing result |
|---|---|
| `flutter build apk` (universal APK), sideloaded APK | ✅ A single `.apk`, installable directly on any Android device |
| Play Store / `flutter build appbundle` | ⚠️ The app is split into several APKs (`info.isSplit == true`). All files are sent, but the recipient must install them together (e.g. with the *SAI* app) |

For an app meant to be shared outside a store, build it with `flutter build apk --release`.

On the recipient's side, Android will ask to allow installs from "unknown sources" for the app that received the file (Files, WhatsApp…). This is expected.

## How it works

1. The plugin reads the path of the installed APK (`ApplicationInfo.sourceDir` + `splitSourceDirs`).
2. It copies it to `cache/share_lelo/` with a readable name (in the background, without blocking the UI).
3. It exposes the file through its own `FileProvider` (authority `<your.package>.share_lelo.fileprovider`, no conflict with other plugins) and opens the Android share sheet with the `application/vnd.android.package-archive` type.

## License

MIT — see [LICENSE](LICENSE).
