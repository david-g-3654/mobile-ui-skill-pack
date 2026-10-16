import 'package:flutter/material.dart';

class SettingsEvalApp extends StatelessWidget {
  const SettingsEvalApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF526747),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF141714)
          : const Color(0xFFF5F5EF),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _SettingsScreen(),
    );
  }
}

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();

  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  bool _notifications = true;
  bool _weeklySummary = false;
  String _appearance = 'System';

  void _showDetails(String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(message, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = switch (_appearance) {
      'Light' => Brightness.light,
      'Dark' => Brightness.dark,
      _ => MediaQuery.platformBrightnessOf(context),
    };
    return Theme(
      data: const SettingsEvalApp()._theme(brightness),
      child: Builder(builder: _buildScreen),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              children: [
                Row(
                  children: [
                    Icon(Icons.spa_outlined, color: colors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text('bloom', style: theme.textTheme.titleLarge),
                    const Spacer(),
                    Text(
                      'YOUR SPACE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text('Settings', style: theme.textTheme.headlineLarge),
                const SizedBox(height: 5),
                Text(
                  'A little more you. A little less noise.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 26),
                _Surface(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showDetails(
                      'Your profile',
                      'Alex Morgan\nalex.morgan@gmail.com\n\nMember since March 2024.',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: dark
                                ? const Color(0xFF454D3C)
                                : const Color(0xFFE9EBD9),
                            child: Text(
                              'AM',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alex Morgan',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'alex.morgan@gmail.com',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colors.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const _SectionLabel('PREFERENCES'),
                _Surface(
                  child: Column(
                    children: [
                      _SettingRow(
                        icon: Icons.notifications_none_rounded,
                        title: 'Push notifications',
                        subtitle: 'Gentle nudges, just for you',
                        trailing: Switch.adaptive(
                          value: _notifications,
                          onChanged: (value) =>
                              setState(() => _notifications = value),
                        ),
                      ),
                      const _InsetDivider(),
                      _SettingRow(
                        icon: Icons.mark_email_unread_outlined,
                        title: 'Weekly recap',
                        subtitle: 'Your week, in a little email',
                        trailing: Switch.adaptive(
                          value: _weeklySummary,
                          onChanged: (value) =>
                              setState(() => _weeklySummary = value),
                        ),
                      ),
                      const _InsetDivider(),
                      _SettingRow(
                        icon: Icons.contrast_rounded,
                        title: 'Appearance',
                        trailing: PopupMenuButton<String>(
                          initialValue: _appearance,
                          tooltip: 'Choose appearance',
                          onSelected: (value) =>
                              setState(() => _appearance = value),
                          itemBuilder: (context) => ['System', 'Light', 'Dark']
                              .map(
                                (value) => PopupMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _appearance,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.unfold_more_rounded,
                                  size: 18,
                                  color: colors.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const _SectionLabel('YOUR MEMBERSHIP'),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: dark
                        ? const Color(0xFF293627)
                        : const Color(0xFFE7EDDD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_outlined,
                            color: colors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'Bloom Plus',
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surface.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'More room to grow.',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Annual plan · Renews March 24, 2027',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.onSurface,
                            side: BorderSide(
                              color: colors.primary.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () => _showDetails(
                            'Bloom Plus',
                            'Your annual plan is active.\n\$39.99 / year\n\nYour next renewal is March 24, 2027. You can manage or cancel your subscription in your device’s subscription settings.',
                          ),
                          child: const Text('Manage subscription'),
                        ),
                      ),
                    ],
                  ),
                ),
                const _SectionLabel('ACCOUNT'),
                _Surface(
                  child: Column(
                    children: [
                      _SettingRow(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal details',
                        onTap: () => _showDetails(
                          'Personal details',
                          'Alex Morgan\nalex.morgan@gmail.com\nAustralia · English',
                        ),
                      ),
                      const _InsetDivider(),
                      _SettingRow(
                        icon: Icons.lock_outline_rounded,
                        title: 'Privacy & security',
                        onTap: () => _showDetails(
                          'Privacy & security',
                          'Your journal is private. Your entries are never shared with other members.\n\nAccount protection: email sign-in enabled.',
                        ),
                      ),
                      const _InsetDivider(),
                      _SettingRow(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & support',
                        onTap: () => _showDetails(
                          'Here to help',
                          'Have a question or a little feedback?\n\nReach our team at support@bloom.example.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: colors.error),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Sign out of Bloom?'),
                        content: const Text(
                          'Your progress will be here when you return.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Stay here'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _showDetails(
                                'Signed out',
                                'You have been signed out of this demo session.',
                              );
                            },
                            child: const Text('Sign out'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign out'),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Made for a little everyday growth.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'BLOOM  ·  VERSION 2.8.1',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF20241F)
        : const Color(0xFFFFFEFA),
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 26, 4, 10),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class _InsetDivider extends StatelessWidget {
  const _InsetDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(left: 56, right: 18),
    child: Divider(),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          ],
        ),
      ),
    );
  }
}
