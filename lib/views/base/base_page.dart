import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/components/mini_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/controllers/config/config_controllers.dart';
import '../../core/repositories/others/onboarding_local.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/ui_util.dart';
import '../auth/dialogs/consent_sheet.dart';
import '../explore/explore_page.dart';
import '../home/home_page/home_page.dart';
import '../saved/saved_page.dart';
import '../settings/settings_page.dart';

class EntryPointUI extends HookConsumerWidget {
  const EntryPointUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = usePageController();
    final selectedIndex = useState(0);
    final currentBackPressTime = useState<DateTime?>(null);
    final canPopNow = useState(false);

    final showConsent =
        ref.watch(configProvider).value?.showCookieConsent ?? false;

    void onTabTap(int index) {
      controller.animateToPage(
        index,
        duration: AppDefaults.duration,
        curve: Curves.ease,
      );
      selectedIndex.value = index;
    }

    void checkIfConsent(BuildContext context, WidgetRef ref) {
      if (!showConsent) return;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final isDone = OnboardingRepository().isConsentDone();
        if (!isDone) {
          UiUtil.openBottomSheet(
              context: context, widget: const CookieConsentSheet());
        }
      });
    }

    useEffect(() {
      checkIfConsent(context, ref);
      return null;
    }, []);

    final isLoggedEnable =
        ref.read(configProvider).value?.isLoginEnabled ?? false;

    final screens = [
      const HomePage(),
      const ExplorePage(),
      if (isLoggedEnable) const SavedPage(),
      const SettingsPage(),
    ];

    final navbarItems = [
      GButton(icon: IconlyLight.home, text: 'home'.tr()),
      GButton(icon: IconlyLight.category, text: 'explore'.tr()),
      if (isLoggedEnable) GButton(icon: IconlyLight.heart, text: 'saved'.tr()),
      GButton(icon: IconlyLight.profile, text: 'settings'.tr()),
    ];

    return PopScope(
      canPop: canPopNow.value,
      onPopInvokedWithResult: (didPop, _) async {
        final now = DateTime.now();
        if (currentBackPressTime.value == null ||
            now.difference(currentBackPressTime.value!) >
                const Duration(seconds: 2)) {
          currentBackPressTime.value = now;
          canPopNow.value = false;
          Fluttertoast.showToast(msg: 'Press back again to exit');
        } else {
          canPopNow.value = true;
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: PageView(
                allowImplicitScrolling: false,
                physics: const NeverScrollableScrollPhysics(),
                controller: controller,
                children: screens,
              ),
            ),
            const MiniPlayer(isOnStack: false),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GNav(
              rippleColor: AppColors.primary.withOpacityValue(0.3),
              hoverColor: Colors.grey.shade700,
              haptic: true,
              tabBorderRadius: AppDefaults.radius,
              curve: Curves.easeIn,
              duration: AppDefaults.duration,
              gap: 8,
              padding: const EdgeInsets.all(AppDefaults.padding),
              color: Colors.grey,
              activeColor: AppColors.primary,
              iconSize: 24,
              tabBackgroundColor: AppColors.primary.withOpacityValue(0.1),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              tabs: navbarItems,
              onTabChange: onTabTap,
              selectedIndex: selectedIndex.value,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
          ),
        ),
      ),
    );
  }
}
