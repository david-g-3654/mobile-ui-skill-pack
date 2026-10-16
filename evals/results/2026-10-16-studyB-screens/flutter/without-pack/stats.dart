import 'package:flutter/material.dart';

class StatsEvalApp extends StatelessWidget {
  const StatsEvalApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF24694F),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF131A17) : const Color(0xFFF6F7F2),
      fontFamily: 'sans-serif',
      dividerColor: dark ? const Color(0xFF344039) : const Color(0xFFE1E5DC),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _StatsScreen(),
    );
  }
}

class _StatsScreen extends StatefulWidget {
  const _StatsScreen();

  @override
  State<_StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<_StatsScreen> {
  int _period = 0;
  int _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final muted = theme.colorScheme.onSurfaceVariant;
    final weekLabel = _weekOffset == 0
        ? 'May 20 – 26, 2024'
        : _weekOffset == -1
            ? 'May 13 – 19, 2024'
            : 'May ${20 + _weekOffset * 7} – ${26 + _weekOffset * 7}, 2024';
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Icon(Icons.directions_run_rounded,
                              color: theme.colorScheme.primary, size: 26),
                          const SizedBox(width: 8),
                          Text('STRIDE',
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3)),
                          const Spacer(),
                          const CircleAvatar(
                            radius: 19,
                            backgroundColor: Color(0xFFE2E9DA),
                            child: Text('JL',
                                style: TextStyle(
                                    color: Color(0xFF35563B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text('Your running,\nin perspective.',
                          style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.2,
                              height: 1.12)),
                      const SizedBox(height: 12),
                      Text('Small steps. Stronger every week.',
                          style: TextStyle(color: muted, fontSize: 14)),
                      const SizedBox(height: 26),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: dark
                              ? const Color(0xFF232E27)
                              : const Color(0xFFE9EDE3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: List.generate(3, (index) {
                            final selected = index == _period;
                            return Expanded(
                              child: Semantics(
                                selected: selected,
                                child: TextButton(
                                  onPressed: () => setState(() => _period = index),
                                  style: TextButton.styleFrom(
                                    backgroundColor: selected
                                        ? theme.colorScheme.surface
                                        : Colors.transparent,
                                    foregroundColor: selected
                                        ? theme.colorScheme.onSurface
                                        : muted,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(['Week', 'Month', 'Year'][index],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Previous week',
                            onPressed: () => setState(() {
                              if (_weekOffset > -2) _weekOffset--;
                            }),
                            icon: const Icon(Icons.chevron_left_rounded),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                    _period == 0
                                        ? weekLabel
                                        : _period == 1
                                            ? 'May 2024'
                                            : '2024',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                const SizedBox(height: 3),
                                Text(_period == 0 ? 'THIS WEEK' : 'OVERVIEW',
                                    style: TextStyle(
                                        color: muted,
                                        fontSize: 10,
                                        letterSpacing: 1.7,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Next week',
                            onPressed: _weekOffset < 0
                                ? () => setState(() => _weekOffset++)
                                : null,
                            icon: const Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _DistanceCard(period: _period, offset: _weekOffset),
                      const SizedBox(height: 16),
                      LayoutBuilder(builder: (context, constraints) {
                        final cards = [
                          _Metric(
                              icon: Icons.timer_outlined,
                              label: 'Time moving',
                              value: _period == 0 ? '3h 12m' : '12h 48m',
                              detail: 'Time well spent'),
                          const _Metric(
                              icon: Icons.speed_rounded,
                              label: 'Avg. pace',
                              value: '5:55',
                              unit: '/km',
                              detail: '12 sec faster',
                              improved: true),
                        ];
                        if (constraints.maxWidth < 300) {
                          return Column(children: [
                            cards[0],
                            const SizedBox(height: 12),
                            cards[1],
                          ]);
                        }
                        return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: cards[0]),
                              const SizedBox(width: 12),
                              Expanded(child: cards[1]),
                            ]);
                      }),
                      const SizedBox(height: 24),
                      _GoalCard(period: _period),
                      const SizedBox(height: 30),
                      Row(children: [
                        Expanded(
                          child: Text('The week in runs',
                              style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        Text('4 RUNS',
                            style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w700,
                                color: muted)),
                      ]),
                      const SizedBox(height: 8),
                      const _RunRow(
                          day: 'SUN',
                          date: '26',
                          title: 'Sunday long run',
                          subtitle: '1h 04m · 6:06 /km',
                          distance: '10.5',
                          longRun: true),
                      const _RunRow(
                          day: 'FRI',
                          date: '24',
                          title: 'A little faster',
                          subtitle: '39m · 5:34 /km',
                          distance: '7.0'),
                      const _RunRow(
                          day: 'WED',
                          date: '22',
                          title: 'Midweek miles',
                          subtitle: '49m · 5:46 /km',
                          distance: '8.5'),
                      const _RunRow(
                          day: 'MON',
                          date: '20',
                          title: 'Easy does it',
                          subtitle: '40m · 6:15 /km',
                          distance: '6.4'),
                      const SizedBox(height: 24),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.spa_outlined, size: 16, color: muted),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text('Consistency looks good on you.',
                              style: TextStyle(color: muted, fontSize: 12)),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index != 1) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(index == 0
                    ? 'You’re all caught up. Ready for your next run?'
                    : 'Weekly goal: 40 km. Keep it going!')));
          }
        },
        backgroundColor: theme.scaffoldBackgroundColor,
        indicatorColor: dark
            ? const Color(0xFF344A38)
            : const Color(0xFFE0E9D7),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.explore_outlined), label: 'Overview'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded), label: 'Statistics'),
          NavigationDestination(
              icon: Icon(Icons.flag_outlined), label: 'Goals'),
        ],
      ),
    );
  }
}

class _DistanceCard extends StatelessWidget {
  const _DistanceCard({required this.period, required this.offset});
  final int period;
  final int offset;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFFF3F7E9);
    final distance = period == 0
        ? (32.4 + offset * 3.6).toStringAsFixed(1)
        : period == 1
            ? '128.6'
            : '542.8';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF234E3D),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.route_rounded, size: 18, color: Color(0xFFCCDCB5)),
          SizedBox(width: 8),
          Text('TOTAL DISTANCE',
              style: TextStyle(
                  color: Color(0xFFCCDCB5),
                  letterSpacing: 1.5,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
          Text(distance,
              style: const TextStyle(
                  color: ink,
                  fontSize: 58,
                  letterSpacing: -2.5,
                  height: 1.15,
                  fontWeight: FontWeight.w600)),
          const Text('km', style: TextStyle(color: Color(0xFFCCDCB5), fontSize: 22)),
        ]),
        const SizedBox(height: 10),
        const Wrap(spacing: 5, runSpacing: 4, children: [
          Text('↗  12.5%',
              style: TextStyle(
                  color: Color(0xFFD3EB97),
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          Text('vs. last week',
              style: TextStyle(color: Color(0xFFCCDCB5), fontSize: 12)),
        ]),
        const SizedBox(height: 26),
        Semantics(
          label: 'Daily distance: Monday 6.4, Tuesday rest, Wednesday 8.5, '
              'Thursday rest, Friday 7, Saturday rest, Sunday 10.5 kilometers.',
          child: ExcludeSemantics(
            child: SizedBox(
              height: 132,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  const values = [6.4, 0.0, 8.5, 0.0, 7.0, 0.0, 10.5];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: values[index] == 0 ? 4 : values[index] * 8,
                            constraints: const BoxConstraints(maxWidth: 32),
                            decoration: BoxDecoration(
                              color: index == 6
                                  ? const Color(0xFFD7EC9F)
                                  : values[index] == 0
                                      ? const Color(0xFF4A6B56)
                                      : const Color(0xFF92B495),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                              style: TextStyle(
                                  fontSize: 11,
                                  color: index == 6
                                      ? ink
                                      : const Color(0xFFB5C8B6))),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    this.unit,
    this.improved = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final String? unit;
  final bool improved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 21, color: theme.colorScheme.primary),
        const SizedBox(height: 13),
        Text(label,
            style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 3, children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  letterSpacing: -0.7,
                  fontWeight: FontWeight.w600)),
          if (unit != null)
            Text(unit!,
                style: TextStyle(
                    fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        ]),
        const SizedBox(height: 9),
        Text(improved ? '↗ $detail' : detail,
            style: TextStyle(
                fontSize: 11,
                color: improved
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.period});
  final int period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: dark ? const Color(0xFF2A3423) : const Color(0xFFECF0DE),
          borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.flag_outlined, size: 21, color: theme.colorScheme.primary),
          const SizedBox(width: 9),
          Expanded(
              child: Text(period == 0 ? 'Weekly goal' : 'Distance goal',
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Text('81%',
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 15),
        LinearProgressIndicator(
          value: .81,
          minHeight: 7,
          borderRadius: BorderRadius.circular(4),
          color: dark ? const Color(0xFFBDD88D) : const Color(0xFF526F39),
          backgroundColor: dark
              ? const Color(0xFF46513A)
              : const Color(0xFFD8E0C8),
        ),
        const SizedBox(height: 12),
        Text('32.4 of 40 km · Just 7.6 km to go',
            style: TextStyle(
                fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _RunRow extends StatelessWidget {
  const _RunRow({
    required this.day,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.distance,
    this.longRun = false,
  });
  final String day;
  final String date;
  final String title;
  final String subtitle;
  final String distance;
  final bool longRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 38,
          child: Column(children: [
            Text(day,
                style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(date,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
            if (longRun) ...[
              const SizedBox(height: 7),
              Text('LONGEST RUN',
                  style: TextStyle(
                      fontSize: 8,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary)),
            ],
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(distance,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
          Text('km',
              style: TextStyle(
                  fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
        ]),
      ]),
    );
  }
}
