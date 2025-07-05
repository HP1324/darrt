import 'package:flutter/material.dart';
import 'package:minimaltodo/app/state/managers/theme_manager.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(50),
        title: Text('Theme Colors'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThemeSelector(context),
            const SizedBox(height: 32),
            Text(
              'Select Your Theme Color',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
            ),
            const SizedBox(height: 20),
            _buildColorGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGrid() {
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
        final color = ThemeColors.values[index];
        final isSelected = g.themeMan.selectedColor == color;

        return _ColorOption(
          color: color.color,
          isSelected: isSelected,
          onTap: () => g.themeMan.setThemeColor(color),
        );
      },
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Theme Mode',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
            listenable: g.themeMan,
            builder: (context, child) {
              return SegmentedButton<ThemePreference>(
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
                selected: {g.themeMan.themePreference},
                onSelectionChanged: (Set<ThemePreference> newSelection) {
                  g.themeMan.setThemePreference(newSelection.first);
                },
              );
            }),
      ],
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
                color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
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
                color: color.computeLuminance() > 0.5 ? Colors.white : Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}
