import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/models/return_request_model.dart';

class ReturnStatusCard extends StatelessWidget {
  final ReturnRequestModel returnRequest;
  final VoidCallback? onViewDetails;

  const ReturnStatusCard({
    super.key,
    required this.returnRequest,
    this.onViewDetails,
  });

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

  IconData _getStatusIcon(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.pending:
        return Icons.schedule;
      case ReturnStatus.approved:
        return Icons.check_circle_outline;
      case ReturnStatus.rejected:
        return Icons.cancel_outlined;
      case ReturnStatus.completed:
        return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(returnRequest.status);
    final statusIcon = _getStatusIcon(returnRequest.status);

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
                Icon(statusIcon, color: statusColor, size: 28),
                const SizedBox(width: AppDefaults.padding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Return Request',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        returnRequest.productName,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    returnRequest.status.displayName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDefaults.padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refund Amount',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'KES ${returnRequest.refundAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Requested On',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      returnRequest.formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
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
            if (onViewDetails != null) ...[
              const SizedBox(height: AppDefaults.padding),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
