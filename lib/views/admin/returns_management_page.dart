import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/constants.dart';
import '../../core/models/return_request_model.dart';
import '../../core/services/return_service.dart';

class ReturnsManagementPage extends ConsumerWidget {
  const ReturnsManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Requests Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('return_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final returns = snapshot.data?.docs ?? [];

          if (returns.isEmpty) {
            return const Center(
              child: Text('No return requests'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDefaults.padding),
            itemCount: returns.length,
            itemBuilder: (context, index) {
              final returnData = ReturnRequestModel.fromMap(
                returns[index].data() as Map<String, dynamic>,
                returns[index].id,
              );
              return _ReturnRequestCard(returnRequest: returnData);
            },
          );
        },
      ),
    );
  }
}

class _ReturnRequestCard extends ConsumerWidget {
  final ReturnRequestModel returnRequest;

  const _ReturnRequestCard({required this.returnRequest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDefaults.padding),
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        returnRequest.productName,
                        style: Theme.of(context).textTheme.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order: ${returnRequest.orderId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'User: ${returnRequest.userId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(returnRequest.status)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    returnRequest.status.displayName,
                    style:
                        Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _getStatusColor(returnRequest.status),
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reason', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      returnRequest.reason,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Refund Amount',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      'KES ${returnRequest.refundAmount}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDefaults.padding),
            Text(
              'Description',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              returnRequest.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (returnRequest.status == ReturnStatus.pending) ...[
              const SizedBox(height: AppDefaults.padding),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveReturn(context, ref),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectReturn(context, ref),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (returnRequest.status == ReturnStatus.approved) ...[
              const SizedBox(height: AppDefaults.padding),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _markAsCompleted(context, ref),
                  icon: const Icon(Icons.task_alt),
                  label: const Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
            if (returnRequest.adminNotes != null) ...[
              const SizedBox(height: AppDefaults.padding),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Notes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      returnRequest.adminNotes!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showEditNotesDialog(context, ref),
                child: const Text('Edit Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.pending:
        return Colors.orange;
      case ReturnStatus.approved:
        return Colors.blue;
      case ReturnStatus.rejected:
        return Colors.red;
      case ReturnStatus.completed:
        return Colors.green;
    }
  }

  Future<void> _approveReturn(BuildContext context, WidgetRef ref) async {
    try {
      final returnService = ReturnService();
      await returnService.updateReturnStatus(
        returnRequest.id,
        ReturnStatus.approved,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return approved')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _rejectReturn(BuildContext context, WidgetRef ref) async {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Return'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            hintText: 'Rejection reason (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final returnService = ReturnService();
                await returnService.updateReturnStatus(
                  returnRequest.id,
                  ReturnStatus.rejected,
                );
                if (notesController.text.isNotEmpty) {
                  await returnService.addAdminNotes(
                    returnRequest.id,
                    notesController.text,
                  );
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Return rejected')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsCompleted(BuildContext context, WidgetRef ref) async {
    try {
      final returnService = ReturnService();
      await returnService.updateReturnStatus(
        returnRequest.id,
        ReturnStatus.completed,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return completed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showEditNotesDialog(BuildContext context, WidgetRef ref) {
    final notesController = TextEditingController(
      text: returnRequest.adminNotes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Admin Notes'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final returnService = ReturnService();
                await returnService.addAdminNotes(
                  returnRequest.id,
                  notesController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notes updated')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
