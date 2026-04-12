import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/mixins/refresh_on_return_mixin.dart';
import '../../core/providers/user_provider.dart';
import 'components/profile_header.dart';
import 'components/profile_menu_options.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with RefreshOnReturnMixin<ProfilePage> {
  @override
  Future<void> onRefreshRequested() async {
    ref.invalidate(userProfileProvider);
    await ref.read(userProfileProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefreshRequested,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: const Column(
              children: [ProfileHeader(), ProfileMenuOptions()],
            ),
          ),
        ),
      ),
    );
  }
}
