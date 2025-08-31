import 'package:darrt/app/ads/my_banner_ad_widget.dart';
import 'package:darrt/app/ads/timed_banner_ad_widget.dart';
import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/theme/theme_controller.dart';
import 'package:darrt/app/theme/theme_enums.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final scheme = context.colorScheme;
    return Scaffold(
      backgroundColor: getSurfaceColor(context),
      appBar: AppBar(
        backgroundColor: scheme.primary.withAlpha(50),
        title: Text('Theme Colors'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ThemeModeSelector(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Select Your Theme Color',
                style: textTheme.titleMedium,
              ),
            ),
            _ColorGrid(),
            ListenableBuilder(
              listenable: g.adsController,
              builder: (context, child) {
                return TimedBannerAdWidget(
                  adInitializer: () =>
                      g.adsController.initializeThemePageBannerAd(),
                  childBuilder: () {
                    if (g.adsController.isThemePageBannerAdLoaded) {
                      return MyBannerAdWidget(
                        bannerAd: g.adsController.themePageBannerAd,
                        adSize: AdSize.banner,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  showFor: Duration(seconds: 100),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends ConsumerWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);

    final themePreference = themeState.preference;

    final textTheme = context.textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Theme Mode',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemePreference>(
            segments: [
              ButtonSegment<ThemePreference>(
                value: ThemePreference.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('System'),
              ),
              ButtonSegment<ThemePreference>(
                value: ThemePreference.light,
                icon: Icon(Icons.light_mode),
                label: Text('Light'),
              ),
              ButtonSegment<ThemePreference>(
                value: ThemePreference.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Dark'),
              ),
            ],
            selected: {themePreference},
            onSelectionChanged: (Set<ThemePreference> newSelection) {
              ref
                  .read(themeControllerProvider.notifier)
                  .setThemePreference(newSelection.first);
            },
          ),
        ],
      ),
    );
  }
}

class _ColorGrid extends ConsumerWidget {
  const _ColorGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final color = themeState.color;
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: ThemeColors.values.length,
      itemBuilder: (context, index) {
        final value = ThemeColors.values[index];
        final isSelected = color == value;

        return _ColorOption(
          color: value.color,
          isSelected: isSelected,
          onTap: () =>
              ref.read(themeControllerProvider.notifier).setThemeColor(value),
        );
      },
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(78),
                  blurRadius: isSelected ? 6 : 0,
                  spreadRadius: isSelected ? 1 : 0,
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: color.computeLuminance() > 0.5
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 14,
                color: color.computeLuminance() > 0.5
                    ? Colors.white
                    : Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}
