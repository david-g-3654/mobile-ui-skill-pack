import 'package:flutter/material.dart';

class SettingsEvalApp extends StatelessWidget {
  const SettingsEvalApp({super.key});

  static const Color _seed = Color(0xFF3D5AFE);

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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

enum _AppearanceMode { system, light, dark }

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
  _AppearanceMode _mode = _AppearanceMode.system;
  bool _reduceMotion = false;
  double _textScale = 1.0;
  int _accent = 0;

  static const List<Color> _accents = [
    Color(0xFF3D5AFE),
    Color(0xFF00897B),
    Color(0xFFE65100),
    Color(0xFFC2185B),
    Color(0xFF6D4C41),
  ];
  static const List<String> _accentNames = ['Indigo', 'Teal', 'Orange', 'Rose', 'Cocoa'];

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            _ProfileCard(onTap: () => _toast('Edit profile')),
            const _SectionHeader('Notifications'),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Push notifications'),
                    subtitle: const Text('Reminders, replies and activity'),
                    value: _push,
                    onChanged: (v) => setState(() => _push = v),
                  ),
                  const _Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.alternate_email),
                    title: const Text('Mentions only'),
                    subtitle: const Text('Only notify when someone tags you'),
                    value: _mentions,
                    onChanged: _push ? (v) => setState(() => _mentions = v) : null,
                  ),
                  const _Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.mail_outline),
                    title: const Text('Weekly email digest'),
                    subtitle: const Text('Sent Mondays at 8:00 AM'),
                    value: _email,
                    onChanged: (v) => setState(() => _email = v),
                  ),
                  const _Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.bedtime_outlined),
                    title: const Text('Quiet hours'),
                    subtitle: Text(_quietHours ? '10:00 PM – 7:00 AM' : 'Off'),
                    value: _quietHours,
                    onChanged: (v) => setState(() => _quietHours = v),
                  ),
                ],
              ),
            ),
            const _SectionHeader('Appearance'),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Theme', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<_AppearanceMode>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(
                                value: _AppearanceMode.system,
                                icon: Icon(Icons.brightness_auto_outlined),
                                label: Text('Auto'),
                              ),
                              ButtonSegment(
                                value: _AppearanceMode.light,
                                icon: Icon(Icons.light_mode_outlined),
                                label: Text('Light'),
                              ),
                              ButtonSegment(
                                value: _AppearanceMode.dark,
                                icon: Icon(Icons.dark_mode_outlined),
                                label: Text('Dark'),
                              ),
                            ],
                            selected: {_mode},
                            onSelectionChanged: (s) => setState(() => _mode = s.first),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Accent color', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (var i = 0; i < _accents.length; i++)
                              _AccentSwatch(
                                color: _accents[i],
                                label: _accentNames[i],
                                selected: _accent == i,
                                onTap: () => setState(() => _accent = i),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const _Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Row(
                      children: [
                        Icon(Icons.format_size, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text('Text size', style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        Text('${(_textScale * 100).round()}%',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.primary)),
                      ],
                    ),
                  ),
                  Slider(
                    value: _textScale,
                    min: 0.85,
                    max: 1.3,
                    divisions: 9,
                    label: '${(_textScale * 100).round()}%',
                    onChanged: (v) => setState(() => _textScale = v),
                  ),
                  const _Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.motion_photos_off_outlined),
                    title: const Text('Reduce motion'),
                    value: _reduceMotion,
                    onChanged: (v) => setState(() => _reduceMotion = v),
                  ),
                ],
              ),
            ),
            const _SectionHeader('Subscription'),
            _SubscriptionCard(
              onManage: () => _toast('Opening plan management'),
            ),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _NavTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Billing history',
                    trailingText: '12 invoices',
                    onTap: () => _toast('Billing history'),
                  ),
                  const _Divider(),
                  _NavTile(
                    icon: Icons.credit_card,
                    title: 'Payment method',
                    trailingText: 'Visa •• 4242',
                    onTap: () => _toast('Payment method'),
                  ),
                  const _Divider(),
                  _NavTile(
                    icon: Icons.restore,
                    title: 'Restore purchases',
                    onTap: () => _toast('Purchases restored'),
                  ),
                ],
              ),
            ),
            const _SectionHeader('Account'),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _NavTile(
                    icon: Icons.mail_outline,
                    title: 'Email',
                    subtitle: 'maya.thompson@example.com',
                    onTap: () => _toast('Change email'),
                  ),
                  const _Divider(),
                  _NavTile(
                    icon: Icons.lock_outline,
                    title: 'Password',
                    subtitle: 'Last changed 3 months ago',
                    onTap: () => _toast('Change password'),
                  ),
                  const _Divider(),
                  _NavTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Two-factor authentication',
                    trailingText: 'On',
                    onTap: () => _toast('Two-factor authentication'),
                  ),
                  const _Divider(),
                  _NavTile(
                    icon: Icons.devices_outlined,
                    title: 'Signed-in devices',
                    trailingText: '3',
                    onTap: () => _toast('Signed-in devices'),
                  ),
                  const _Divider(),
                  _NavTile(
                    icon: Icons.download_outlined,
                    title: 'Export my data',
                    onTap: () => _toast('We’ll email you a download link'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign out'),
                    onTap: () => _confirm(
                      title: 'Sign out?',
                      body: 'You’ll need to sign in again on this device.',
                      action: 'Sign out',
                    ),
                  ),
                  const _Divider(),
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: scheme.error),
                    title: Text('Delete account', style: TextStyle(color: scheme.error)),
                    subtitle: const Text('Permanently remove your account and data'),
                    onTap: () => _confirm(
                      title: 'Delete account?',
                      body:
                          'This permanently deletes your projects, notes and subscription history. This can’t be undone.',
                      action: 'Delete',
                      destructive: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Version 4.12.0 (2381)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm({
    required String title,
    required String body,
    required String action,
    bool destructive = false,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError)
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    if (ok == true && mounted) _toast('$action confirmed');
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                child: Text('MT',
                    style: text.titleMedium?.copyWith(
                        color: scheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Maya Thompson',
                        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('maya.thompson@example.com',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text('Member since March 2022',
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
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

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.onManage});
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const used = 38.4;
    const total = 100.0;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.workspace_premium, color: scheme.onPrimaryContainer),
                Text('Pro Annual',
                    style: text.titleMedium?.copyWith(
                        color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Active',
                      style: text.labelSmall?.copyWith(color: scheme.onPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('\$59.99 / year · Renews on Feb 18, 2027',
                style: text.bodyMedium?.copyWith(color: scheme.onPrimaryContainer)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Cloud storage',
                      style: text.labelLarge?.copyWith(color: scheme.onPrimaryContainer)),
                ),
                Text('${used.toStringAsFixed(1)} of ${total.toInt()} GB',
                    style: text.labelMedium?.copyWith(color: scheme.onPrimaryContainer)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: used / total,
                minHeight: 8,
                backgroundColor: scheme.onPrimaryContainer.withValues(alpha: 0.15),
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonal(
                onPressed: onManage,
                child: const Text('Manage plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
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
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? scheme.onSurface : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: selected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      child: Semantics(
        header: true,
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
