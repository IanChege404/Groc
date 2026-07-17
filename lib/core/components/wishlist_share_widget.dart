import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_defaults.dart';

class WishlistShareWidget extends StatefulWidget {
  final String shareCode;
  final String shareLink;
  final VoidCallback onCopyLink;

  const WishlistShareWidget({
    super.key,
    required this.shareCode,
    required this.shareLink,
    required this.onCopyLink,
  });

  @override
  State<WishlistShareWidget> createState() => _WishlistShareWidgetState();
}

class _WishlistShareWidgetState extends State<WishlistShareWidget> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share Your Wishlist',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _ShareCodeDisplay(code: widget.shareCode),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CopyButton(
                  label: _copied ? 'Copied!' : 'Copy Code',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.shareCode));
                    setState(() => _copied = true);
                    widget.onCopyLink();
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _copied = false);
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ShareButton(
                  onPressed: () => _shareViaWhatsApp(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareViaWhatsApp(BuildContext context) {
    final message =
        'Check out my wishlist! Use code: ${widget.shareCode}\n${widget.shareLink}';
    final encodedMessage = Uri.encodeComponent(message);
    // Implementation would use url_launcher to open WhatsApp
    widget.onCopyLink();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link ready to share: ${widget.shareCode}')),
    );
  }
}

class _ShareCodeDisplay extends StatelessWidget {
  final String code;

  const _ShareCodeDisplay({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
      child: Text(
        code,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 2,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _CopyButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.content_copy_rounded),
      label: Text(label),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ShareButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.share_rounded),
      label: const Text('Share'),
    );
  }
}
