import 'package:flutter/material.dart';
import 'package:share_lelo/share_lelo.dart';

void main() => runApp(const MaterialApp(home: ShareApkPage()));

class ShareApkPage extends StatelessWidget {
  const ShareApkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('share_lelo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<ApkInfo>(
              future: ShareLelo.getApkInfo(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                if (info == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.android, size: 40),
                    title: Text('${info.appName} v${info.versionName}'),
                    subtitle: Text(
                      '${info.formattedSize}'
                      '${info.isSplit ? ' • ${info.splitApkPaths.length + 1} APK files' : ''}',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // The whole integration: one widget.
            const ShareApkButton(text: 'Install my app 🚀'),
            const SizedBox(height: 12),
            const ShareApkButton(
              packageName: 'com.android.bluetooth',
              icon: Icon(Icons.bluetooth),
              label: Text('Send via Bluetooth'),
            ),
          ],
        ),
      ),
    );
  }
}
