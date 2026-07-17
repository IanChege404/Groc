import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/bundle_model.dart';
import '../../core/providers/bundle_management_provider.dart';

class BundleEditPage extends ConsumerStatefulWidget {
  final BundleModel bundle;

  const BundleEditPage({super.key, required this.bundle});

  @override
  ConsumerState<BundleEditPage> createState() => _BundleEditPageState();
}

class _BundleEditPageState extends ConsumerState<BundleEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bundle.name);
    _descriptionController =
        TextEditingController(text: widget.bundle.description);
    _priceController = TextEditingController(
      text: widget.bundle.price.toStringAsFixed(2),
    );
    _discountController = TextEditingController(
      text: (widget.bundle.discountPrice ?? 0).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.editBundle),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BundleDetailsSection(
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                ),
                const SizedBox(height: 24),
                _PricingSection(
                  priceController: _priceController,
                  discountController: _discountController,
                ),
                const SizedBox(height: 24),
                _ProductsSection(bundle: widget.bundle),
                const SizedBox(height: 24),
                _ActionButtons(
                  onSave: () => _saveChanges(),
                  onDelete: () => _deleteBundle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveChanges() {
    final l10n = AppLocalizations.of(context)!;
    final updates = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.tryParse(_priceController.text) ?? widget.bundle.price,
      'discountPrice': double.tryParse(_discountController.text),
    };

    ref
        .read(updateBundleDetailsProvider(
      (widget.bundle.id, updates),
    ).future)
        .whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bundleUpdatedSuccessfully)),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToLoadProducts),
          action: SnackBarAction(
            label: l10n.tryAgain,
            onPressed: _saveChanges,
          ),
        ),
      );
    });
  }

  void _deleteBundle() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    bool isDeleteEnabled = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.deleteBundleQuestion),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.deleteBundleWarning),
              const SizedBox(height: 16),
              Text(
                l10n.typeDeleteToConfirm(widget.bundle.name),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: widget.bundle.name,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setDialogState(() {
                    isDeleteEnabled = value == widget.bundle.name;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: isDeleteEnabled
                  ? () {
                      ref
                          .read(deleteBundleProvider(widget.bundle.id).future)
                          .whenComplete(() {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.bundleDeleted)),
                        );
                      }).catchError((error) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.failedToLoadProducts),
                            action: SnackBarAction(
                              label: l10n.tryAgain,
                              onPressed: _deleteBundle,
                            ),
                          ),
                        );
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                disabledBackgroundColor: Colors.red.shade100,
              ),
              child: Text(l10n.confirmDelete),
            ),
          ],
        ),
      ),
    );
  }
}

class _BundleDetailsSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const _BundleDetailsSection({
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bundleDetails,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.bundleName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.description,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _PricingSection extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController discountController;

  const _PricingSection({
    required this.priceController,
    required this.discountController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pricing,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.priceKes,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.discountPrice,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductsSection extends StatelessWidget {
  final BundleModel bundle;

  const _ProductsSection({required this.bundle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.productsInBundle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            FilledButton.tonal(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.addProductComingSoon),
                  ),
                );
              },
              child: Text(l10n.addProduct),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bundle.itemNames.length,
          separatorBuilder: (context, index) => const Divider(height: 24),
          itemBuilder: (context, index) {
            return _ProductItem(
              name: bundle.itemNames[index],
              productId: bundle.productIds[index],
            );
          },
        ),
      ],
    );
  }
}

class _ProductItem extends StatelessWidget {
  final String name;
  final String productId;

  const _ProductItem({
    required this.name,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name),
              const SizedBox(height: 4),
              Text(
                'ID: $productId',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.removeProductComingSoon),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onDelete;

  const _ActionButtons({
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_rounded),
            label: Text(l10n.saveChanges),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l10n.deleteBundle),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
