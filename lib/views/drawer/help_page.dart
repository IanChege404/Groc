import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/constants.dart';
import '../../core/themes/app_themes.dart';
import 'components/help_models.dart';
import 'components/help_topics.dart';
import 'components/top_questions.dart';

const List<HelpTopicItem> _allTopics = [
  HelpTopicItem('My Account', '/profileEdit'),
  HelpTopicItem('Payment and Wallet', '/wallet'),
  HelpTopicItem('Shipping & Delivery', '/deliveryAddress'),
  HelpTopicItem('Vouchers & Promotions', '/coupon'),
  HelpTopicItem('Ordering', '/myOrder'),
];

const List<HelpQuestionItem> _allQuestions = [
  HelpQuestionItem(
    'How do I return my items?',
    'Open My Orders, select the order, and tap "Report an Issue" within 24 hours of delivery. Choose "Return item" and follow the prompts — approved returns are refunded to your Pro Grocery Wallet.',
  ),
  HelpQuestionItem(
    'How do I use a collection point?',
    'At checkout, choose "Pickup" instead of "Delivery" and select a nearby collection point. You will get a notification and a pickup code once your order is ready.',
  ),
  HelpQuestionItem(
    'What is Pro Grocery?',
    'Pro Grocery is a mobile grocery marketplace that lets you order fresh produce and household essentials from local vendors, with support for M-Pesa, card, and wallet payments.',
  ),
  HelpQuestionItem(
    'How can I add a new delivery address?',
    'Go to Profile > Delivery Address > Add New Address, then pin your location on the map or enter it manually. You can save multiple addresses and set a default.',
  ),
  HelpQuestionItem(
    'How can I avail of Sticker Price offers?',
    'Sticker Price items are discounted products flagged directly on the product card. Add them to your cart before the offer countdown ends — availability is limited per store.',
  ),
];

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAnswer(HelpQuestionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppDefaults.padding,
          right: AppDefaults.padding,
          top: AppDefaults.padding,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              AppDefaults.padding * 1.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.question,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDefaults.padding),
            Text(item.answer),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filteredTopics = query.isEmpty
        ? _allTopics
        : _allTopics
            .where((t) => t.label.toLowerCase().contains(query))
            .toList();
    final filteredQuestions = query.isEmpty
        ? _allQuestions
        : _allQuestions
            .where((q) => q.question.toLowerCase().contains(query))
            .toList();

    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: const Text('Help')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi! How can we help?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _SearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
              if (filteredQuestions.isEmpty && filteredTopics.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDefaults.padding * 2,
                  ),
                  child: Text(
                    'No results for "$query". Try a different search term.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              if (filteredQuestions.isNotEmpty)
                TopQuestions(
                  items: filteredQuestions,
                  onTap: _showAnswer,
                ),
              if (filteredTopics.isNotEmpty)
                HelpTopics(
                  items: filteredTopics,
                  onTap: (topic) => context.push(topic.route),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(inputDecorationTheme: AppTheme.secondaryInputDecorationTheme),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDefaults.padding),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'Search',
            suffixIcon: SvgPicture.asset(
              AppIcons.search,
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.placeholder,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
