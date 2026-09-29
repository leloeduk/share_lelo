import 'package:flutter/material.dart';
import 'package:share_lelo/share_lelo.dart';

void main() => runApp(const MaterialApp(home: ShareApkPage()));

class ShareApkPage extends StatefulWidget {
  const ShareApkPage({super.key});

  @override
  State<ShareApkPage> createState() => _ShareApkPageState();
}

class _ShareApkPageState extends State<ShareApkPage> {
  ApkInfo? _info;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    ShareLelo.getApkInfo().then((info) => setState(() => _info = info));
  }

  Future<void> _share({String? packageName}) async {
    setState(() => _loading = true);
    try {
      await ShareLelo.shareApk(
        text: 'Installe mon application 🚀',
        packageName: packageName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Scaffold(
      appBar: AppBar(title: const Text('share_lelo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (info == null)
              const Center(child: CircularProgressIndicator())
            else
              Card(
                child: ListTile(
                  leading: const Icon(Icons.android, size: 40),
                  title: Text('${info.appName} v${info.versionName}'),
                  subtitle: Text(
                    '${info.formattedSize}'
                    '${info.isSplit ? ' • ${info.splitApkPaths.length + 1} fichiers APK' : ''}',
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loading ? null : () => _share(),
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share),
              label: const Text("Partager l'application"),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loading
                  ? null
                  : () => _share(packageName: 'com.android.bluetooth'),
              icon: const Icon(Icons.bluetooth),
              label: const Text('Envoyer par Bluetooth'),
            ),
          ],
        ),
      ),
    );
  }
}
