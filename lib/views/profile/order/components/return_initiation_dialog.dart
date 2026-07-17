import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/models/order_item_model.dart';
import '../../../../core/models/return_request_model.dart';
import '../../../../core/providers/return_provider.dart';
import '../../../../core/services/firestore_auth_service.dart';
import '../../../../core/services/return_service.dart';

class ReturnInitiationDialog extends ConsumerStatefulWidget {
  final OrderItemModel item;
  final String orderId;
  final double itemPrice;

  const ReturnInitiationDialog({
    super.key,
    required this.item,
    required this.orderId,
    required this.itemPrice,
  });

  @override
  ConsumerState<ReturnInitiationDialog> createState() =>
      _ReturnInitiationDialogState();
}

class _ReturnInitiationDialogState
    extends ConsumerState<ReturnInitiationDialog> {
  late String _selectedReason;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  static const List<String> returnReasons = [
    'Damaged or defective',
    'Not as described',
    'Wrong item received',
    'Changed mind',
    'Quality issues',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedReason = returnReasons.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReturn() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a description')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = FirestoreAuthService();
      final currentUser = await authService.getCurrentUser();

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in first')),
        );
        return;
      }

      final returnRequest = ReturnRequestModel(
        id: '',
        orderId: widget.orderId,
        userId: currentUser.uid,
        productId: widget.item.id,
        productName: widget.item.productName,
        productImage: widget.item.image,
        reason: _selectedReason,
        description: _descriptionController.text.trim(),
        status: ReturnStatus.pending,
        createdAt: DateTime.now(),
        refundAmount: widget.itemPrice,
        itemCount: widget.item.quantity,
      );

      final returnService = ReturnService();
      await returnService.initializeReturn(returnRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Return request submitted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Request Return',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppDefaults.padding),
              Text(
                'Product: ${widget.item.productName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Refund Amount: KES ${widget.itemPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppDefaults.padding * 2),
              Text(
                'Reason for Return',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedReason,
                isExpanded: true,
                items: returnReasons
                    .map((reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedReason = value);
                  }
                },
              ),
              const SizedBox(height: AppDefaults.padding * 2),
              Text(
                'Description',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Please describe the issue',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: AppDefaults.padding * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReturn,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Return Request'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
