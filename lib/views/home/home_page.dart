import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/constants/app_icons.dart';

import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import 'components/ad_space.dart';
import 'components/our_new_item.dart';
import 'components/popular_packs.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Semantics(
                  button: true,
                  label: l10n.sidebarMenu,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/drawerPage');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textInputBackground,
                      shape: const CircleBorder(),
                    ),
                    child: SvgPicture.asset(AppIcons.sidebarIcon),
                  ),
                ),
              ),
              floating: true,
              title: Semantics(
                label: l10n.appName,
                child: SvgPicture.asset(
                  "assets/images/app_logo.svg",
                  height: 32,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  child: Semantics(
                    button: true,
                    label: l10n.searchButton,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/search');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textInputBackground,
                        shape: const CircleBorder(),
                      ),
                      child: SvgPicture.asset(AppIcons.search),
                    ),
                  ),
                ),
              ],
            ),
            const SliverToBoxAdapter(
              child: AdSpace(),
            ),
            const SliverToBoxAdapter(
              child: PopularPacks(),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: AppDefaults.padding),
              sliver: SliverToBoxAdapter(
                child: OurNewItem(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
