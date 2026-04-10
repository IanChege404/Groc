import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../views/home/components/animated_dots.dart';
import '../constants/constants.dart';
import 'network_image.dart';

class ProductImagesSlider extends StatefulWidget {
  const ProductImagesSlider({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  State<ProductImagesSlider> createState() => _ProductImagesSliderState();
}

class _ProductImagesSliderState extends State<ProductImagesSlider>
    with TickerProviderStateMixin {
  late PageController controller;
  late AnimationController _popController;
  late Animation<double> _popAnimation;
  int currentIndex = 0;
  bool _isLiked = false;

  List<String> images = [];

  @override
  void initState() {
    super.initState();
    images = widget.images;
    controller = PageController();
    _setupPopAnimation();
  }

  void _setupPopAnimation() {
    _popController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _popAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );
  }

  Future<void> _triggerPopAnimation() async {
    setState(() => _isLiked = !_isLiked);
    await _popController.forward().then((_) {
      _popController.reset();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: AppColors.coloredBackground,
        borderRadius: AppDefaults.borderRadius,
      ),
      height: MediaQuery.of(context).size.height * 0.35,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (v) {
                    currentIndex = v;
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(AppDefaults.padding),
                      child: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: NetworkImageWithLoader(
                          images[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                  itemCount: images.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: AnimatedDots(
                  totalItems: images.length,
                  currentIndex: currentIndex,
                ),
              )
            ],
          ),
          Positioned(
            right: 0,
            child: ScaleTransition(
              scale: _popAnimation,
              child: Material(
                color: Colors.transparent,
                borderRadius: AppDefaults.borderRadius,
                child: IconButton(
                  onPressed: _triggerPopAnimation,
                  iconSize: 56,
                  constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
                  icon: Container(
                    padding: const EdgeInsets.all(AppDefaults.padding),
                    decoration: const BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      _isLiked ? AppIcons.heartActive : AppIcons.heart,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
