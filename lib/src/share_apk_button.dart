import 'package:flutter/material.dart';

import '../share_lelo.dart';

/// A ready-to-use button that shares the app's APK.
///
/// Shows a spinner while the APK is being copied, disables itself to avoid
/// double taps, and reports errors with a [SnackBar] (or [onError]).
///
/// ```dart
/// const ShareApkButton()
/// ```
class ShareApkButton extends StatefulWidget {
  /// Creates a button that calls [ShareLelo.shareApk] when pressed.
  const ShareApkButton({
    super.key,
    this.label = const Text('Share app'),
    this.icon = const Icon(Icons.share),
    this.fileName,
    this.chooserTitle,
    this.text,
    this.subject,
    this.packageName,
    this.onShared,
    this.onError,
    this.style,
  });

  /// Button label. Defaults to `Text('Share app')`.
  final Widget label;

  /// Button icon. Defaults to [Icons.share].
  final Widget icon;

  /// See [ShareLelo.shareApk].
  final String? fileName;

  /// See [ShareLelo.shareApk].
  final String? chooserTitle;

  /// See [ShareLelo.shareApk].
  final String? text;

  /// See [ShareLelo.shareApk].
  final String? subject;

  /// See [ShareLelo.shareApk], e.g. `com.android.bluetooth`.
  final String? packageName;

  /// Called with the shared file paths once the share sheet is open.
  final ValueChanged<List<String>>? onShared;

  /// Called when sharing fails. When `null`, a [SnackBar] is shown instead.
  final void Function(Object error)? onError;

  /// Optional style for the underlying [FilledButton].
  final ButtonStyle? style;

  @override
  State<ShareApkButton> createState() => _ShareApkButtonState();
}

class _ShareApkButtonState extends State<ShareApkButton> {
  bool _loading = false;

  Future<void> _share() async {
    setState(() => _loading = true);
    try {
      final paths = await ShareLelo.shareApk(
        fileName: widget.fileName,
        chooserTitle: widget.chooserTitle,
        text: widget.text,
        subject: widget.subject,
        packageName: widget.packageName,
      );
      widget.onShared?.call(paths);
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!(e);
      } else if (mounted) {
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(SnackBar(content: Text('Could not share app: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: widget.style,
      onPressed: _loading || !ShareLelo.isSupported ? null : _share,
      icon: _loading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : widget.icon,
      label: widget.label,
    );
  }
}
