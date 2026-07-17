import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/models/return_request_model.dart';
import '../../../../core/services/shipping_label_service.dart';

class ShippingLabelCard extends ConsumerStatefulWidget {
  final ReturnRequestModel returnRequest;
  final String userAddress;

  const ShippingLabelCard({
    super.key,
    required this.returnRequest,
    required this.userAddress,
  });

  @override
  ConsumerState<ShippingLabelCard> createState() => _ShippingLabelCardState();
}

class _ShippingLabelCardState extends ConsumerState<ShippingLabelCard> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.padding / 2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: AppDefaults.padding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping Label',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        widget.returnRequest.isApproved
                            ? 'Your return has been approved'
                            : 'Awaiting approval',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDefaults.padding),
            if (widget.returnRequest.isApproved) ...[
              StreamBuilder<ShippingLabel?>(
                stream: ShippingLabelService()
                    .getShippingLabel(widget.returnRequest.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    final label = snapshot.data!;
                    return _buildLabelInfo(context, label);
                  }

                  // No label generated yet
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Generate your shipping label to send back your return.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isGenerating ? null : _generateShippingLabel,
                          icon: const Icon(Icons.download),
                          label: _isGenerating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Generate Shipping Label'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Awaiting approval. Shipping label will be available once approved.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabelInfo(BuildContext context, ShippingLabel label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Shipping Label Ready',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLabelRow(
                'Tracking Number',
                label.trackingNumber,
                context,
              ),
              const SizedBox(height: 8),
              _buildLabelRow(
                'Carrier',
                label.carrierName,
                context,
              ),
              const SizedBox(height: 8),
              _buildLabelRow(
                'Estimated Weight',
                '${label.weight} kg',
                context,
              ),
              const SizedBox(height: 12),
              Text(
                'Return From:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label.fromAddress,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Ship To:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label.toAddress,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _downloadLabel(context, label),
            icon: const Icon(Icons.download),
            label: const Text('Download Label (PDF)'),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelRow(
    String label,
    String value,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Future<void> _generateShippingLabel() async {
    setState(() => _isGenerating = true);

    try {
      final service = ShippingLabelService();
      await service.generateShippingLabel(
        widget.returnRequest,
        widget.userAddress,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shipping label generated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _downloadLabel(BuildContext context, ShippingLabel label) {
    // Show dialog with shipping label details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shipping Label'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogRow('Tracking:', label.trackingNumber),
              const SizedBox(height: 8),
              _buildDialogRow('Carrier:', label.carrierName),
              const SizedBox(height: 8),
              _buildDialogRow('Weight:', '${label.weight} kg'),
              const SizedBox(height: 16),
              Text(
                'Please print this label and attach it to your return package.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Return From:\n${label.fromAddress}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Ship To:\n${label.toAddress}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // In production, this would open a PDF viewer or download
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF download would be triggered here'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
