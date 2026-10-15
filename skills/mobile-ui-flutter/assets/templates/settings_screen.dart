// settings_screen.dart — Settings archetype (mobile-ui/references/screen-settings.md).
// Inset-grouped sections on canvas. Toggles apply immediately. Destructive actions last.
// Copy and sample data here are examples for a fictional app — reuse the structure, write your own words.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool dailyReminder = true;
  bool weeklyReport = false;

  Future<void> _confirmDelete() async {
    final q = context.q;
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Delete your account?'),
        content: const Text("Your journals and settings will be permanently removed. This can't be undone."),
        actions: [
          adaptiveAction(context, label: 'Keep my account', onPressed: () => Navigator.pop(context, false)),
          adaptiveAction(context,
              label: 'Delete account', destructive: true, color: q.negative, onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );
    if (confirmed == true) {
      // Call your API, then route to the signed-out flow.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Settings')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xs, QSpace.margin, QSpace.xxl),
            sliver: SliverList.list(
              children: [
                QGroupedSection(children: [
                  QListRow(
                    leading: const QAvatar(name: 'Amara Okafor', size: 48),
                    title: 'Amara Okafor',
                    subtitle: 'amara@hey.com',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: QSpace.xxl),
                QGroupedSection(
                  header: 'Preferences',
                  footer: 'Reminders arrive 10 minutes before your wake-up time.',
                  children: [
                    QListRow(title: 'Appearance', value: 'System', onTap: () {}),
                    QListRow(title: 'Wake up', value: '8:00 AM', onTap: () {}),
                    QToggleRow(
                      title: 'Daily reminder',
                      value: dailyReminder,
                      onChanged: (v) => setState(() => dailyReminder = v),
                    ),
                  ],
                ),
                const SizedBox(height: QSpace.xxl),
                QGroupedSection(header: 'Notifications', children: [
                  QToggleRow(
                    title: 'Weekly report',
                    subtitle: 'A summary every Sunday evening',
                    value: weeklyReport,
                    onChanged: (v) => setState(() => weeklyReport = v),
                  ),
                ]),
                const SizedBox(height: QSpace.xxl),
                QGroupedSection(header: 'Subscription', children: [
                  const QListRow(title: 'Plan', value: 'Pro · renews Oct 3'),
                  QListRow(title: 'Restore purchases', kind: QRowKind.action, onTap: () {}),
                ]),
                const SizedBox(height: QSpace.xxl),
                QGroupedSection(children: [
                  QListRow(title: 'Privacy policy', kind: QRowKind.link, onTap: () {}),
                ]),
                const SizedBox(height: QSpace.xxl),
                QGroupedSection(children: [
                  QListRow(title: 'Sign out', kind: QRowKind.action, onTap: () {}),
                  QListRow(title: 'Delete account', kind: QRowKind.action, destructive: true, onTap: _confirmDelete),
                ]),
                const SizedBox(height: QSpace.xl),
                Text('Quiet 4.2.0 (1182)', style: context.qText.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog action that renders as CupertinoDialogAction on iOS and TextButton elsewhere.
Widget adaptiveAction(BuildContext context,
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
