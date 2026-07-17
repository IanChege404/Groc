import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/network_image.dart';
import '../../core/constants/constants.dart';
import '../../core/models/review_model.dart';
import '../../core/providers/review_provider.dart';
import '../../core/services/firestore_auth_service.dart';

class SubmitReviewPage extends ConsumerStatefulWidget {
  final String productId;
  final String? productName;
  final String? productImage;

  const SubmitReviewPage({
    super.key,
    required this.productId,
    this.productName,
    this.productImage,
  });

  @override
  ConsumerState<SubmitReviewPage> createState() => _SubmitReviewPageState();
}

class _SubmitReviewPageState extends ConsumerState<SubmitReviewPage> {
  int _rating = 5;
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = FirestoreAuthService();
      final currentUser = await authService.getCurrentUser();

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to submit a review')),
        );
        return;
      }

      final review = ReviewModel(
        id: '',
        productId: widget.productId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Anonymous',
        userImage: currentUser.photoURL ?? '',
        rating: _rating.toDouble(),
        title: _titleController.text.trim(),
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      final reviewService = ref.read(reviewServiceProvider);
      await reviewService.submitReview(review);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
        context.pop();
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
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Submit Review'),
      ),
      backgroundColor: AppColors.cardColor,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(AppDefaults.padding),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding * 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: AppDefaults.borderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: widget.productImage != null
                      ? NetworkImageWithLoader(widget.productImage!)
                      : Container(
                          color: AppColors.primary,
                          child: const Icon(Icons.image, size: 50),
                        ),
                ),
              ),
              if (widget.productName != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.productName!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: Text(
                  'How would you rate the\nquality of this product?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () => setState(() => _rating = index + 1),
                    child: Icon(
                      index < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFFFC107),
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDefaults.padding * 3),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Title (Optional)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter review title',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: AppDefaults.padding * 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Comment',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Share your experience with this product',
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
              ),
              const SizedBox(height: AppDefaults.padding * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
