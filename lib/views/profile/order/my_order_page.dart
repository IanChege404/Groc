import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/providers/order_provider.dart';
import 'components/custom_tab_label.dart';
import 'components/tab_all.dart';
import 'components/tab_completed.dart';
import 'components/tab_running.dart';

class AllOrderPage extends ConsumerWidget {
  const AllOrderPage({super.key});

  bool _isRunningStatus(String status) {
    return status == 'pending' ||
        status == 'processing' ||
        status == 'shipped' ||
        status == 'delivery';
  }

  bool _isCompletedStatus(String status) {
    return status == 'completed' || status == 'cancelled';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    final orders = ordersState.maybeWhen(
      data: (items) => items,
      orElse: () => const <OrderModel>[],
    );

    final runningOrders = orders
        .where((o) => _isRunningStatus(o.status))
        .toList();
    final completedOrders = orders
        .where((o) => _isCompletedStatus(o.status))
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('My Order'),
          bottom: TabBar(
            physics: NeverScrollableScrollPhysics(),
            tabs: [
              CustomTabLabel(label: 'All', value: '(${orders.length})'),
              CustomTabLabel(
                label: 'Running',
                value: '(${runningOrders.length})',
              ),
              CustomTabLabel(
                label: 'Previous',
                value: '(${completedOrders.length})',
              ),
            ],
          ),
        ),
        body: Container(
          color: AppColors.cardColor,
          child: TabBarView(
            children: [
              AllTab(orders: orders),
              RunningTab(orders: runningOrders),
              CompletedTab(orders: completedOrders),
            ],
          ),
        ),
      ),
    );
  }
}
