// Settings archetype (mobile-ui/references/screen-settings.md).
// Job: change preferences and manage the account. Focal: the account header row.
// Primary action: none — toggles apply immediately; destructive actions sit in the last group.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

class SettingsEvalApp extends StatelessWidget {
  const SettingsEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tidepool',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _SettingsScreen(),
    );
  }
}

enum _Theme { system, light, dark }

extension on _Theme {
  String get label => switch (this) {
        _Theme.system => 'System',
        _Theme.light => 'Light',
        _Theme.dark => 'Dark',
      };
}

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();

  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  _Theme _theme = _Theme.system;
  String _playerStyle = 'Artwork';
  bool _newEpisodes = true;
  bool _downloadsReady = true;
  bool _weeklyDigest = false;
  bool _quietHours = true;

  Future<void> _pickTheme() async {
    final picked = await showModalBottomSheet<_Theme>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ChoiceSheet<_Theme>(
        title: 'Theme',
        options: _Theme.values,
        selected: _theme,
        labelOf: (t) => t.label,
      ),
    );
    if (picked != null && mounted) {
      HapticFeedback.selectionClick();
      setState(() => _theme = picked);
    }
  }

  Future<void> _pickPlayerStyle() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ChoiceSheet<String>(
        title: 'Now playing screen',
        options: const ['Artwork', 'Transcript', 'Chapters'],
        selected: _playerStyle,
        labelOf: (s) => s,
      ),
    );
    if (picked != null && mounted) {
      HapticFeedback.selectionClick();
      setState(() => _playerStyle = picked);
    }
  }

  Future<void> _confirm({
    required String title,
    required String message,
    required String keepLabel,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final q = context.q;
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(message),
        actions: [
          _adaptiveAction(context, label: keepLabel, onPressed: () => Navigator.pop(context, false)),
          _adaptiveAction(
            context,
            label: confirmLabel,
            destructive: destructive,
            color: q.negative,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      HapticFeedback.mediumImpact();
      // Call the account API here, then route to the signed-out flow.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Settings')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, Space.xxl),
            sliver: SliverList.list(
              children: [
                GroupedSection(children: [
                  ListRow(
                    leading: const Avatar(name: 'Priya Raman', size: 48),
                    title: 'Priya Raman',
                    subtitle: 'priya.raman@fastmail.com',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: Space.xxl),
                GroupedSection(
                  header: 'Appearance',
                  children: [
                    ListRow(title: 'Theme', value: _theme.label, onTap: _pickTheme),
                    ListRow(title: 'Now playing screen', value: _playerStyle, onTap: _pickPlayerStyle),
                    ListRow(title: 'App icon', value: 'Low tide', onTap: () {}),
                  ],
                ),
                const SizedBox(height: Space.xxl),
                GroupedSection(
                  header: 'Notifications',
                  footer: 'During quiet hours (10 PM – 7 AM) alerts are delivered silently and collected in your inbox.',
                  children: [
                    ToggleRow(
                      title: 'New episodes',
                      subtitle: 'From the 14 shows you follow',
                      value: _newEpisodes,
                      onChanged: (v) => setState(() => _newEpisodes = v),
                    ),
                    ToggleRow(
                      title: 'Downloads ready',
                      value: _downloadsReady,
                      onChanged: (v) => setState(() => _downloadsReady = v),
                    ),
                    ToggleRow(
                      title: 'Weekly listening recap',
                      value: _weeklyDigest,
                      onChanged: (v) => setState(() => _weeklyDigest = v),
                    ),
                    ToggleRow(
                      title: 'Quiet hours',
                      value: _quietHours,
                      onChanged: (v) => setState(() => _quietHours = v),
                    ),
                  ],
                ),
                const SizedBox(height: Space.xxl),
                GroupedSection(
                  header: 'Subscription',
                  footer: 'Billed yearly through the App Store. Cancel any time before Mar 18 to avoid the next charge.',
                  children: [
                    ListRow(title: 'Tidepool Plus', value: r'$34.99 / year', onTap: () {}),
                    const ListRow(title: 'Renews', value: 'Mar 18, 2027'),
                    ListRow(title: 'Restore purchases', kind: RowKind.action, onTap: () {}),
                  ],
                ),
                const SizedBox(height: Space.xxl),
                GroupedSection(
                  header: 'Account',
                  children: [
                    ListRow(title: 'Email', value: 'Verified', onTap: () {}),
                    ListRow(title: 'Password', value: 'Changed 4 months ago', onTap: () {}),
                    ListRow(title: 'Signed-in devices', value: '3', onTap: () {}),
                    ListRow(title: 'Export listening history', onTap: () {}),
                    ListRow(title: 'Privacy policy', kind: RowKind.link, onTap: () {}),
                  ],
                ),
                const SizedBox(height: Space.xxl),
                GroupedSection(children: [
                  ListRow(
                    title: 'Sign out',
                    kind: RowKind.action,
                    onTap: () => _confirm(
                      title: 'Sign out of Tidepool?',
                      message: 'Downloaded episodes stay on this iPhone until you sign in again.',
                      keepLabel: 'Stay signed in',
                      confirmLabel: 'Sign out',
                    ),
                  ),
                  ListRow(
                    title: 'Delete account',
                    kind: RowKind.action,
                    destructive: true,
                    onTap: () => _confirm(
                      title: 'Delete your account?',
                      message:
                          "Your follows, queue and 212 hours of listening history will be erased. Your Plus subscription must be cancelled separately. This can't be undone.",
                      keepLabel: 'Keep my account',
                      confirmLabel: 'Delete account',
                      destructive: true,
                    ),
                  ),
                ]),
                const SizedBox(height: Space.xl),
                Text('Tidepool 3.8.1 (2045)', style: context.t.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-choice sheet: the current value carries a check, tapping a row commits and closes.
class _ChoiceSheet<T> extends StatelessWidget {
  const _ChoiceSheet({required this.title, required this.options, required this.selected, required this.labelOf});

  final String title;
  final List<T> options;
  final T selected;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.margin, 0, Space.margin, Space.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.md,
        children: [
          Semantics(header: true, child: Text(title, style: context.t.titleLarge)),
          GroupedSection(children: [
            for (final option in options)
              Semantics(
                selected: option == selected,
                child: ListRow(
                  title: labelOf(option),
                  kind: RowKind.action,
                  trailing: option == selected ? Icon(Icons.check_rounded, size: 20, color: q.ink) : null,
                  onTap: () => Navigator.pop(context, option),
                ),
              ),
          ]),
        ],
      ),
    );
  }
}

/// Dialog action that renders as CupertinoDialogAction on iOS and TextButton elsewhere.
Widget _adaptiveAction(BuildContext context,
    {required String label, required VoidCallback onPressed, bool destructive = false, Color? color}) {
  final platform = Theme.of(context).platform;
  if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
    return CupertinoDialogAction(isDestructiveAction: destructive, onPressed: onPressed, child: Text(label));
  }
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(foregroundColor: destructive ? color : context.q.ink),
    child: Text(label),
  );
}
