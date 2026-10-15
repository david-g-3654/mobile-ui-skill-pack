// Settings — tab-root settings screen for "Margin", a reading & highlights app.
// Archetype: Settings. Job: change preferences and manage the account.
// Focal: the account header row. Primary action: none (toggles apply immediately).
// Cutting: row icons (none anywhere, so nothing to mix), upsell banners (user is already Pro).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack04/components.dart';
import 'package:fl_eval/pack04/theme.dart';

class SettingsEvalApp extends StatelessWidget {
  const SettingsEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Margin',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _SettingsScreen(),
    );
  }
}

// ── Sample data ─────────────────────────────────────────────────────

class _Account {
  const _Account({required this.name, required this.email, required this.memberSince});
  final String name;
  final String email;
  final String memberSince;
}

class _Subscription {
  const _Subscription({required this.plan, required this.price, required this.renews});
  final String plan;
  final String price;
  final String renews;
}

const _account = _Account(name: 'Priya Raman', email: 'priya.raman@fastmail.com', memberSince: 'Reader since March 2023');
const _subscription = _Subscription(plan: 'Margin Pro · Annual', price: r'$34.99 / year', renews: 'Nov 18, 2026');
const _appVersion = 'Margin 3.8.1 (2140)';

enum _Appearance { system, light, dark }

extension on _Appearance {
  String get label => switch (this) {
        _Appearance.system => 'System',
        _Appearance.light => 'Light',
        _Appearance.dark => 'Dark',
      };
}

const _readingFonts = ['Literata', 'Source Serif', 'Inter', 'Atkinson Hyperlegible'];

// ── Screen ──────────────────────────────────────────────────────────

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();

  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  bool _push = true;
  bool _dailyDigest = true;
  bool _replies = true;
  bool _productNews = false;
  _Appearance _appearance = _Appearance.system;
  String _readingFont = _readingFonts.first;
  bool _justifyText = false;

  Future<void> _pickAppearance() async {
    final picked = await showModalBottomSheet<_Appearance>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ChoiceSheet<_Appearance>(
        title: 'Appearance',
        note: 'System follows your device’s light and dark schedule.',
        options: _Appearance.values,
        selected: _appearance,
        labelOf: (a) => a.label,
      ),
    );
    if (picked != null) setState(() => _appearance = picked);
  }

  Future<void> _pickFont() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ChoiceSheet<String>(
        title: 'Reading font',
        note: 'Applies to articles and books. Menus keep the system font.',
        options: _readingFonts,
        selected: _readingFont,
        labelOf: (f) => f,
      ),
    );
    if (picked != null) setState(() => _readingFont = picked);
  }

  Future<void> _confirmSignOut() async {
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Sign out of Margin?'),
        content: const Text('Your highlights stay synced to your account. Downloaded articles are removed from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign out')),
        ],
      ),
    );
    if (ok == true && mounted) {
      HapticFeedback.mediumImpact();
      showQToast(context, 'Signed out');
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Delete your account?'),
        content: const Text(
            'This permanently deletes 1,284 highlights and 96 saved articles. Cancel Margin Pro in the App Store first so you’re not charged again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep account')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.q.negative),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      HapticFeedback.heavyImpact();
      showQToast(context, 'We’ve emailed a link to confirm deletion');
    }
  }

  void _soon(String what) => showQToast(context, '$what opens here');

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Settings')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xs, QSpace.margin, QSpace.xxl),
            sliver: SliverList.list(
              children: [
                // Account header — the closest thing to a focal element.
                QGroupedSection(
                  children: [
                    QListRow(
                      leading: QAvatar(name: _account.name, size: 48),
                      title: _account.name,
                      subtitle: _account.email,
                      onTap: () => _soon('Profile'),
                    ),
                  ],
                ),
                const SizedBox(height: QSpace.xxl),

                QGroupedSection(
                  header: 'Notifications',
                  footer: 'The daily digest arrives at 7:30 AM with highlights from what you saved yesterday.',
                  children: [
                    QToggleRow(
                      title: 'Push notifications',
                      value: _push,
                      onChanged: (v) => setState(() => _push = v),
                    ),
                    QToggleRow(
                      title: 'Daily digest',
                      value: _dailyDigest && _push,
                      onChanged: (v) => setState(() {
                        _dailyDigest = v;
                        if (v) _push = true;
                      }),
                    ),
                    QToggleRow(
                      title: 'Replies to your notes',
                      value: _replies && _push,
                      onChanged: (v) => setState(() {
                        _replies = v;
                        if (v) _push = true;
                      }),
                    ),
                    QToggleRow(
                      title: 'Product news by email',
                      subtitle: 'About one email a month',
                      value: _productNews,
                      onChanged: (v) => setState(() => _productNews = v),
                    ),
                  ],
                ),
                const SizedBox(height: QSpace.xxl),

                QGroupedSection(
                  header: 'Appearance',
                  children: [
                    QListRow(title: 'Theme', value: _appearance.label, onTap: _pickAppearance),
                    QListRow(title: 'Reading font', value: _readingFont, onTap: _pickFont),
                    QToggleRow(
                      title: 'Justify text',
                      value: _justifyText,
                      onChanged: (v) => setState(() => _justifyText = v),
                    ),
                  ],
                ),
                const SizedBox(height: QSpace.xxl),

                QGroupedSection(
                  header: 'Subscription',
                  footer: 'Billed through the App Store. Renews automatically unless you cancel at least 24 hours before.',
                  children: [
                    QListRow(
                      title: _subscription.plan,
                      subtitle: '${_subscription.price} · renews ${_subscription.renews}',
                      onTap: () => _soon('Plan details'),
                    ),
                    QListRow(
                      title: 'Manage in App Store',
                      kind: QRowKind.link,
                      onTap: () => _soon('App Store subscriptions'),
                    ),
                    QListRow(
                      title: 'Restore purchases',
                      kind: QRowKind.action,
                      onTap: () => showQToast(context, 'Margin Pro is already active'),
                    ),
                  ],
                ),
                const SizedBox(height: QSpace.xxl),

                QGroupedSection(
                  header: 'Account',
                  footer: _account.memberSince,
                  children: [
                    QListRow(title: 'Email', value: 'priya.raman@…', onTap: () => _soon('Change email')),
                    QListRow(title: 'Password', onTap: () => _soon('Change password')),
                    QListRow(title: 'Signed-in devices', value: '3', onTap: () => _soon('Devices')),
                    QListRow(title: 'Export highlights', onTap: () => _soon('Export')),
                  ],
                ),
                const SizedBox(height: QSpace.xxl),

                QGroupedSection(
                  children: [
                    QListRow(title: 'Sign out', kind: QRowKind.action, onTap: _confirmSignOut),
                    QListRow(
                      title: 'Delete account',
                      kind: QRowKind.action,
                      destructive: true,
                      onTap: _confirmDelete,
                    ),
                  ],
                ),
                const SizedBox(height: QSpace.xl),

                Text(
                  _appVersion,
                  textAlign: TextAlign.center,
                  style: context.qText.bodySmall?.copyWith(color: q.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Choice sheet (theme, reading font) ──────────────────────────────

class _ChoiceSheet<T> extends StatelessWidget {
  const _ChoiceSheet({
    required this.title,
    required this.note,
    required this.options,
    required this.selected,
    required this.labelOf,
  });

  final String title;
  final String note;
  final List<T> options;
  final T selected;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(QSpace.margin, 0, QSpace.margin, QSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: QSpace.md,
        children: [
          Semantics(header: true, child: Text(title, style: context.qText.titleLarge)),
          QGroupedSection(
            footer: note,
            children: [
              for (final option in options)
                Semantics(
                  selected: option == selected,
                  child: QListRow(
                    title: labelOf(option),
                    kind: QRowKind.action,
                    trailing: option == selected ? Icon(Icons.check_rounded, size: 20, color: q.accent) : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context, option);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
