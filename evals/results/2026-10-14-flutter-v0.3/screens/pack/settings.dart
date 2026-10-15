// Settings — Tally (personal budgeting app).
// Archetype: settings. Job: change preferences and manage the account.
// Focal: the account header row. Primary action: none — toggles apply immediately,
// destructive actions sit in their own last group behind a system confirmation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

class SettingsEvalApp extends StatelessWidget {
  const SettingsEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tally',
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
  const _Account({
    required this.name,
    required this.email,
    required this.plan,
    required this.renewsOn,
    required this.yearlyPrice,
    required this.linkedBanks,
  });

  final String name;
  final String email;
  final String plan;
  final String renewsOn;
  final String yearlyPrice;
  final int linkedBanks;
}

const _account = _Account(
  name: 'Priya Raman',
  email: 'priya.raman@fastmail.com',
  plan: 'Tally Plus',
  renewsOn: 'Mar 4, 2027',
  yearlyPrice: r'$34.99',
  linkedBanks: 3,
);

const _appVersion = 'Tally 5.12.0 (2291)';

enum _ThemeChoice {
  system('Match system'),
  light('Light'),
  dark('Dark');

  const _ThemeChoice(this.label);
  final String label;
}

// ── Screen ──────────────────────────────────────────────────────────

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();

  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  bool _pushEnabled = true;
  bool _billReminders = true;
  bool _weeklySummary = false;
  bool _largeSpendAlerts = true;
  bool _hideBalances = false;
  _ThemeChoice _theme = _ThemeChoice.system;

  Future<void> _pickTheme() async {
    final choice = await showModalBottomSheet<_ThemeChoice>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ThemeSheet(current: _theme),
    );
    if (choice != null && mounted) setState(() => _theme = choice);
  }

  Future<void> _confirm({
    required String title,
    required String message,
    required String verb,
    bool destructive = false,
  }) async {
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive ? TextButton.styleFrom(foregroundColor: context.q.negative) : null,
            child: Text(verb),
          ),
        ],
      ),
    );
    if (ok == true) HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Settings')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, Space.xxl),
            sliver: SliverList.list(
              children: [
                // Account header — the closest thing to a focal element.
                GroupedSection(
                  children: [
                    ListRow(
                      leading: Avatar(name: _account.name, size: 48),
                      title: _account.name,
                      subtitle: _account.email,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: Space.xxl),

                GroupedSection(
                  header: 'Notifications',
                  footer: 'Bill reminders arrive two days before a payment is due. '
                      'Large-spend alerts fire for any purchase over \$250.',
                  children: [
                    ToggleRow(
                      title: 'Push notifications',
                      value: _pushEnabled,
                      onChanged: (v) => setState(() => _pushEnabled = v),
                    ),
                    ToggleRow(
                      title: 'Bill reminders',
                      value: _billReminders,
                      onChanged: (v) => setState(() => _billReminders = v),
                    ),
                    ToggleRow(
                      title: 'Large-spend alerts',
                      value: _largeSpendAlerts,
                      onChanged: (v) => setState(() => _largeSpendAlerts = v),
                    ),
                    ToggleRow(
                      title: 'Weekly summary email',
                      value: _weeklySummary,
                      onChanged: (v) => setState(() => _weeklySummary = v),
                    ),
                    ListRow(title: 'Quiet hours', value: '10 PM – 7 AM', onTap: () {}),
                  ],
                ),
                const SizedBox(height: Space.xxl),

                GroupedSection(
                  header: 'Appearance',
                  footer: 'Hidden balances show as •••• until you tap them.',
                  children: [
                    ListRow(title: 'Theme', value: _theme.label, onTap: _pickTheme),
                    ListRow(title: 'App icon', value: 'Classic', onTap: () {}),
                    ToggleRow(
                      title: 'Hide balances on launch',
                      value: _hideBalances,
                      onChanged: (v) => setState(() => _hideBalances = v),
                    ),
                  ],
                ),
                const SizedBox(height: Space.xxl),

                GroupedSection(
                  header: 'Subscription',
                  footer: 'Billed ${_account.yearlyPrice} a year through the App Store. '
                      'Cancel any time before ${_account.renewsOn}.',
                  children: [
                    ListRow(
                      title: _account.plan,
                      value: 'Renews ${_account.renewsOn}',
                      onTap: () {},
                    ),
                    ListRow(
                      title: 'Restore purchases',
                      kind: RowKind.action,
                      onTap: () => showToast(context, 'Purchases restored'),
                    ),
                  ],
                ),
                const SizedBox(height: Space.xxl),

                GroupedSection(
                  header: 'Account',
                  children: [
                    ListRow(title: 'Sign-in & security', onTap: () {}),
                    ListRow(
                      title: 'Connected banks',
                      value: '${_account.linkedBanks}',
                      onTap: () {},
                    ),
                    ListRow(title: 'Export transactions', value: 'CSV', onTap: () {}),
                    ListRow(title: 'Privacy policy', kind: RowKind.link, onTap: () {}),
                  ],
                ),
                const SizedBox(height: Space.xxl),

                GroupedSection(
                  children: [
                    ListRow(
                      title: 'Sign out',
                      kind: RowKind.action,
                      onTap: () => _confirm(
                        title: 'Sign out of Tally?',
                        message: 'Your budgets stay synced. You can sign back in with '
                            '${_account.email}.',
                        verb: 'Sign out',
                      ),
                    ),
                    ListRow(
                      title: 'Delete account',
                      kind: RowKind.action,
                      destructive: true,
                      onTap: () => _confirm(
                        title: 'Delete your account?',
                        message: 'This removes your budgets, ${_account.linkedBanks} bank connections '
                            'and 4 years of history. It can’t be undone.',
                        verb: 'Delete account',
                        destructive: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.xl),

                Text(
                  _appVersion,
                  textAlign: TextAlign.center,
                  style: context.t.bodySmall?.copyWith(color: q.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Theme picker sheet ──────────────────────────────────────────────

class _ThemeSheet extends StatelessWidget {
  const _ThemeSheet({required this.current});

  final _ThemeChoice current;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Space.margin, 0, Space.margin, Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.md,
        children: [
          Semantics(header: true, child: Text('Theme', style: context.t.titleLarge)),
          GroupedSection(
            footer: 'Match system follows your phone’s light and dark schedule.',
            children: [
              for (final choice in _ThemeChoice.values)
                Semantics(
                  selected: choice == current,
                  child: ListRow(
                    title: choice.label,
                    kind: RowKind.action,
                    trailing: choice == current
                        ? Icon(Icons.check_rounded, size: 20, color: q.accent)
                        : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop(choice);
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
