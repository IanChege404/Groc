import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import 'components/category_tile.dart';
import 'package:go_router/go_router.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'Choose a category',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          const CateogoriesGrid(),
        ],
      ),
    );
  }
}

class CateogoriesGrid extends StatelessWidget {
  const CateogoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 3,
        children: [
          CategoryTile(
            imageLink: 'https://i.imgur.com/tGChxbZ.png',
            label: 'Vegetables',
            backgroundColor: AppColors.primary,
            onTap: () {
              context.push('/categoryDetails', extra: {
                'categoryId': 'vegetables',
                'categoryName': 'Vegetables',
              });
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/yOFxoIP.png',
            label: 'Meat And Fish',
            onTap: () {
              context.push('/categoryDetails', extra: {
                'categoryId': 'meat_fish',
                'categoryName': 'Meat And Fish',
              });
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/GPsRaFC.png',
            label: 'Medicine',
            onTap: () {
              context.push('/categoryDetails', extra: {
                'categoryId': 'medicine',
                'categoryName': 'Medicine',
              });
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/mGRqfnc.png',
            label: 'Baby Care',
            onTap: () {
              context.push('/categoryDetails', extra: {
                'categoryId': 'baby_care',
                'categoryName': 'Baby Care',
              });
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/fwyz4oC.png',
            label: 'Office Supplies',
            onTap: () {
              context.push('/categoryDetails', extra: {
                'categoryId': 'office_supplies',
                'categoryName': 'Office Supplies',
              });
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/DNr8a6R.png',
            label: 'Beauty',
            onTap: () {
              context.push('/categoryDetails', extra: {
                'categoryId': 'beauty',
                'categoryName': 'Beauty',
              });
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/O2ZX5nR.png',
            label: 'Gym Equipment',
            onTap: () {
              context.push('/categoryDetails', extra: {
                'categoryId': 'gym_equipment',
                'categoryName': 'Gym Equipment',
              });
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/wJBopjL.png',
            label: 'Gardening Tools',
            onTap: () {
              context.push('/categoryDetails', extra: {
                'categoryId': 'gardening_tools',
                'categoryName': 'Gardening Tools',
              });
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/P4yJA9t.png',
            label: 'Pet Care',
            onTap: () {
              context.push('/categoryDetails', extra: {
                'categoryId': 'pet_care',
                'categoryName': 'Pet Care',
              });
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/sxGf76e.png',
            label: 'Eye Wears',
            onTap: () {
              context.push('/categoryDetails', extra: {
                'categoryId': 'eye_wears',
                'categoryName': 'Eye Wears',
              });
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/BPvKeXl.png',
            label: 'Pack',
            onTap: () {
              context.push('/categoryDetails');
            },
          ),
          CategoryTile(
            imageLink: 'https://i.imgur.com/m65fusg.png',
            label: 'Others',
            onTap: () {
              context.push('/categoryDetails');
            },
          ),
        ],
      ),
    );
  }
}
