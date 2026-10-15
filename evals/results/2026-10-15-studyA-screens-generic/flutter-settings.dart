import 'package:flutter/material.dart';

class SettingsEvalApp extends StatelessWidget {
  const SettingsEvalApp({super.key});

  static const Color _seed = Color(0xFF3F5AA8);

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        foregroundColor: scheme.onSurface,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _SettingsScreen(),
    );
  }
}

enum _ThemeChoice { system, light, dark }

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();

  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  bool _push = true;
  bool _email = false;
  bool _mentions = true;
  bool _quietHours = true;
  _ThemeChoice _themeChoice = _ThemeChoice.system;
  bool _reduceMotion = false;
  int _accent = 0;

  static const _accents = <(String, Color)>[
    ('Indigo', Color(0xFF3F5AA8)),
    ('Teal', Color(0xFF00897B)),
    ('Coral', Color(0xFFE5674F)),
    ('Plum', Color(0xFF8E4DA8)),
    ('Amber', Color(0xFFC88A12)),
  ];

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'You’ll need to sign in again to sync your notes on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true) _toast('Signed out');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Settings')),
          SliverSafeArea(
            top: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.list(
                children: [
                  _ProfileCard(onTap: () => _toast('Opening profile')),
                  const _SectionHeader('Notifications'),
                  Card(
                    child: Column(
                      children: [
                        _SwitchRow(
                          icon: Icons.notifications_active_outlined,
                          title: 'Push notifications',
                          subtitle: 'Reminders, replies and shared notes',
                          value: _push,
                          onChanged: (v) => setState(() => _push = v),
                        ),
                        const Divider(indent: 56),
                        _SwitchRow(
                          icon: Icons.alternate_email,
                          title: 'Mentions only',
                          subtitle: 'Only notify when someone @mentions you',
                          value: _mentions,
                          onChanged: _push
                              ? (v) => setState(() => _mentions = v)
                              : null,
                        ),
                        const Divider(indent: 56),
                        _SwitchRow(
                          icon: Icons.mail_outline,
                          title: 'Weekly email digest',
                          subtitle: 'A summary every Monday morning',
                          value: _email,
                          onChanged: (v) => setState(() => _email = v),
                        ),
                        const Divider(indent: 56),
                        _SwitchRow(
                          icon: Icons.bedtime_outlined,
                          title: 'Quiet hours',
                          subtitle: _quietHours
                              ? '10:00 PM – 7:00 AM, every day'
                              : 'Off',
                          value: _quietHours,
                          onChanged: (v) => setState(() => _quietHours = v),
                        ),
                      ],
                    ),
                  ),
                  const _SectionHeader('Appearance'),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('Theme',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _ThemePicker(
                            value: _themeChoice,
                            onChanged: (v) =>
                                setState(() => _themeChoice = v),
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text('Accent color',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                          child: Text(
                            _accents[_accent].$1,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
                          child: Wrap(
                            children: [
                              for (var i = 0; i < _accents.length; i++)
                                _AccentSwatch(
                                  label: _accents[i].$1,
                                  color: _accents[i].$2,
                                  selected: i == _accent,
                                  onTap: () => setState(() => _accent = i),
                                ),
                            ],
                          ),
                        ),
                        const Divider(),
                        _NavRow(
                          icon: Icons.format_size,
                          title: 'Text size',
                          value: 'Uses system setting',
                          onTap: () => _toast('Opening text size'),
                        ),
                        const Divider(indent: 56),
                        _SwitchRow(
                          icon: Icons.animation,
                          title: 'Reduce motion',
                          subtitle: 'Minimize animations and transitions',
                          value: _reduceMotion,
                          onChanged: (v) => setState(() => _reduceMotion = v),
                        ),
                      ],
                    ),
                  ),
                  const _SectionHeader('Subscription'),
                  _PlanCard(onManage: () => _toast('Opening subscription')),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        _NavRow(
                          icon: Icons.receipt_long_outlined,
                          title: 'Billing history',
                          value: 'Last charged Sep 12',
                          onTap: () => _toast('Opening billing history'),
                        ),
                        const Divider(indent: 56),
                        _NavRow(
                          icon: Icons.credit_card,
                          title: 'Payment method',
                          value: 'Visa •••• 4821',
                          onTap: () => _toast('Opening payment method'),
                        ),
                        const Divider(indent: 56),
                        _NavRow(
                          icon: Icons.restore,
                          title: 'Restore purchases',
                          onTap: () => _toast('Purchases restored'),
                        ),
                      ],
                    ),
                  ),
                  const _SectionHeader('Account'),
                  Card(
                    child: Column(
                      children: [
                        _NavRow(
                          icon: Icons.mail_outline,
                          title: 'Email',
                          value: 'maya.okafor@fieldnote.app',
                          onTap: () => _toast('Opening email'),
                        ),
                        const Divider(indent: 56),
                        _NavRow(
                          icon: Icons.lock_outline,
                          title: 'Password & security',
                          value: 'Two-step verification on',
                          onTap: () => _toast('Opening security'),
                        ),
                        const Divider(indent: 56),
                        _NavRow(
                          icon: Icons.devices_outlined,
                          title: 'Signed-in devices',
                          value: '3 devices',
                          onTap: () => _toast('Opening devices'),
                        ),
                        const Divider(indent: 56),
                        _NavRow(
                          icon: Icons.download_outlined,
                          title: 'Export your data',
                          onTap: () => _toast('Preparing export'),
                        ),
                        const Divider(indent: 56),
                        _NavRow(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy',
                          onTap: () => _toast('Opening privacy'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Sign out'),
                          onTap: _confirmSignOut,
                        ),
                        const Divider(indent: 56),
                        ListTile(
                          leading: Icon(Icons.delete_outline,
                              color: scheme.error),
                          title: Text('Delete account',
                              style: TextStyle(color: scheme.error)),
                          onTap: () => _toast(
                              'We’ll email you to confirm account deletion'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Fieldnote 4.12.0 (2381)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text('MO',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Maya Okafor', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'maya.okafor@fieldnote.app',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: value == null ? null : Text(value!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.value, required this.onChanged});
  final _ThemeChoice value;
  final ValueChanged<_ThemeChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(14) > 20;
    final segments = <ButtonSegment<_ThemeChoice>>[
      ButtonSegment(
        value: _ThemeChoice.system,
        icon: const Icon(Icons.brightness_auto_outlined),
        label: const Text('System'),
      ),
      ButtonSegment(
        value: _ThemeChoice.light,
        icon: const Icon(Icons.light_mode_outlined),
        label: const Text('Light'),
      ),
      ButtonSegment(
        value: _ThemeChoice.dark,
        icon: const Icon(Icons.dark_mode_outlined),
        label: const Text('Dark'),
      ),
    ];
    if (large) {
      // At large text sizes a horizontal segmented control truncates; fall
      // back to a vertical list of radio-style choices.
      return Column(
        children: [
          for (final s in segments)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: s.icon,
              title: s.label,
              trailing: value == s.value
                  ? Icon(Icons.check,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
              selected: value == s.value,
              onTap: () => onChanged(s.value),
            ),
        ],
      );
    }
    return SegmentedButton<_ThemeChoice>(
      segments: segments,
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label accent',
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? scheme.onSurface : Colors.transparent,
                  width: 2.5,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 20, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.onManage});
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.workspace_premium,
                    color: scheme.onPrimaryContainer),
                Text(
                  'Fieldnote Pro',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Active',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: scheme.onPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$4.99 / month · Renews Oct 12, 2026',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.62,
                minHeight: 6,
                backgroundColor:
                    scheme.onPrimaryContainer.withValues(alpha: 0.15),
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '12.4 GB of 20 GB cloud storage used',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: onManage,
                  child: const Text('Manage plan'),
                ),
                TextButton(
                  onPressed: onManage,
                  style: TextButton.styleFrom(
                      foregroundColor: scheme.onPrimaryContainer),
                  child: const Text('Compare plans'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
