import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/components/app_back_button.dart';
import 'components/review_lists.dart';
import 'components/review_overview.dart';

class ReviewPage extends StatelessWidget {
  final String productId;
  final String? productName;
  final String? productImage;

  const ReviewPage({
    super.key,
    required this.productId,
    this.productName,
    this.productImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => context.push(
              '/submitReview',
              extra: {
                'productId': productId,
                'productName': productName,
                'productImage': productImage,
              },
            ),
            tooltip: 'Add Review',
          ),
        ],
      ),
      body: Column(
        children: [
          ReviewOverview(productId: productId),
          const Divider(thickness: 0.1),
          ReviewLists(productId: productId),
        ],
      ),
    );
  }
}
