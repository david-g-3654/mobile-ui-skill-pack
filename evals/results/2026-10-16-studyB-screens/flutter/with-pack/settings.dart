import 'package:flutter/material.dart';
import 'package:fl_eval/pack04/theme.dart';
import 'package:fl_eval/pack04/components.dart';

class SettingsEvalApp extends StatelessWidget {
  const SettingsEvalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: quietTheme(Brightness.light),
    darkTheme: quietTheme(Brightness.dark),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home: const _SettingsScreen(),
  );
}

enum _Appearance { system, light, dark }

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();

  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailDigest = false;
  _Appearance _appearance = _Appearance.system;

  String get _appearanceLabel => switch (_appearance) {
    _Appearance.system => 'System',
    _Appearance.light => 'Light',
    _Appearance.dark => 'Dark',
  };

  void _showDetails(BuildContext context, String title, List<Widget> children) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            QSpace.margin,
            QSpace.xs,
            QSpace.margin,
            QSpace.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: QSpace.xl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: QSpace.sm,
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(title, style: sheetContext.qText.titleLarge),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close $title',
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseAppearance(BuildContext context) async {
    final selection = await showModalBottomSheet<_Appearance>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(QSpace.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: QSpace.md,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text('Appearance', style: sheetContext.qText.titleLarge),
              ),
              Text(
                'Choose a look, or follow your device.',
                style: sheetContext.qText.bodyMedium,
              ),
              QGroupedSection(
                children: [
                  for (final option in _Appearance.values)
                    Semantics(
                      selected: option == _appearance,
                      child: QListRow(
                        title: switch (option) {
                          _Appearance.system => 'Use device settings',
                          _Appearance.light => 'Light',
                          _Appearance.dark => 'Dark',
                        },
                        kind: QRowKind.action,
                        trailing: option == _appearance
                            ? Icon(
                                Icons.check_rounded,
                                color: sheetContext.q.ink,
                              )
                            : null,
                        onTap: () => Navigator.pop(sheetContext, option),
                      ),
                    ),
                ],
              ),
              QTertiaryButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      ),
    );
    if (selection != null && mounted) {
      setState(() => _appearance = selection);
    }
  }

  void _confirmAccountAction(BuildContext context, {required bool delete}) {
    final action = delete ? 'Delete account' : 'Sign out';
    showAdaptiveDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: Text('$action?'),
        content: Text(
          delete
              ? 'This would permanently remove your account and saved entries. Account deletion is unavailable in this preview.'
              : 'You’re viewing a sample account. Signing out is unavailable in this preview.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep my account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = switch (_appearance) {
      _Appearance.system => Theme.of(context),
      _Appearance.light => quietTheme(Brightness.light),
      _Appearance.dark => quietTheme(Brightness.dark),
    };
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => Scaffold(
          body: CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('Settings')),
              SliverSafeArea(
                top: false,
                sliver: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    QSpace.margin,
                    QSpace.xs,
                    QSpace.margin,
                    QSpace.xxl,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: QSpace.xxl,
                      children: [
                        QGroupedSection(
                          children: [
                            QListRow(
                              leading: ExcludeSemantics(
                                child: CircleAvatar(
                                  radius: QSpace.xl,
                                  backgroundColor: context.q.surface2,
                                  child: Text(
                                    'ML',
                                    style: context.qText.titleMedium,
                                  ),
                                ),
                              ),
                              title: 'Maya Laurent',
                              subtitle: 'maya.laurent@hey.com',
                              onTap: () => _showProfile(context),
                            ),
                          ],
                        ),
                        QGroupedSection(
                          header: 'Notifications',
                          footer:
                              'A little nudge for your daily writing ritual.',
                          children: [
                            QToggleRow(
                              title: 'Daily reminder',
                              subtitle: 'Every evening at 8:30 PM',
                              value: _pushNotifications,
                              onChanged: (value) =>
                                  setState(() => _pushNotifications = value),
                            ),
                            QToggleRow(
                              title: 'Weekly email recap',
                              value: _emailDigest,
                              onChanged: (value) =>
                                  setState(() => _emailDigest = value),
                            ),
                          ],
                        ),
                        QGroupedSection(
                          header: 'Appearance',
                          children: [
                            QListRow(
                              title: 'Color theme',
                              value: _appearanceLabel,
                              onTap: () => _chooseAppearance(context),
                            ),
                          ],
                        ),
                        QGroupedSection(
                          header: 'Subscription',
                          children: [
                            QListRow(
                              title: 'Still Plus',
                              subtitle: 'Annual plan · Renews Nov 16, 2026',
                              onTap: () => _showDetails(
                                context,
                                'Your subscription',
                                [
                                  Text(
                                    'Still Plus gives you unlimited journals, photo entries, and encrypted backups.',
                                    style: context.qText.bodyLarge,
                                  ),
                                  const QGroupedSection(
                                    children: [
                                      QListRow(title: 'Plan', value: 'Annual'),
                                      QListRow(
                                        title: 'Renewal price',
                                        value: '\$29.99',
                                      ),
                                      QListRow(
                                        title: 'Renews',
                                        subtitle: 'November 16, 2026',
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'This is a sample subscription. No charges or billing changes can be made in this preview.',
                                    style: context.qText.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            QListRow(
                              title: 'Restore purchases',
                              kind: QRowKind.action,
                              onTap: () => showQToast(
                                context,
                                'Your sample Plus plan is already active.',
                              ),
                            ),
                          ],
                        ),
                        QGroupedSection(
                          header: 'Account',
                          children: [
                            QListRow(
                              title: 'Personal information',
                              onTap: () => _showProfile(context),
                            ),
                            QListRow(
                              title: 'Privacy & security',
                              onTap: () =>
                                  _showDetails(context, 'Privacy & security', [
                                    const QGroupedSection(
                                      children: [
                                        QListRow(
                                          title: 'Sign-in method',
                                          value: 'Apple',
                                        ),
                                        QListRow(
                                          title: 'Journal backups',
                                          subtitle: 'Protected with end-to-end encryption',
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'These are sample account details. Your writing stays yours.',
                                      style: context.qText.bodyMedium,
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                        QGroupedSection(
                          children: [
                            QListRow(
                              title: 'Sign out',
                              kind: QRowKind.action,
                              onTap: () =>
                                  _confirmAccountAction(context, delete: false),
                            ),
                            QListRow(
                              title: 'Delete account',
                              kind: QRowKind.action,
                              destructive: true,
                              onTap: () =>
                                  _confirmAccountAction(context, delete: true),
                            ),
                          ],
                        ),
                        Text(
                          'Still · Version 2.8.1 (204)',
                          textAlign: TextAlign.center,
                          style: context.qText.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfile(BuildContext context) =>
      _showDetails(context, 'Personal information', [
        const QGroupedSection(
          children: [
            QListRow(title: 'Name', subtitle: 'Maya Laurent'),
            QListRow(title: 'Email', subtitle: 'maya.laurent@hey.com'),
            QListRow(title: 'Member since', subtitle: 'February 2025'),
          ],
        ),
        Text(
          'You’re viewing a sample Still account.',
          style: context.qText.bodyMedium,
        ),
      ]);
}
