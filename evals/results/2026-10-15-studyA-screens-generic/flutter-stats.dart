import 'dart:math' as math;

import 'package:flutter/material.dart';

class StatsEvalApp extends StatelessWidget {
  const StatsEvalApp({super.key});

  static const Color _seed = Color(0xFFFF5A36);

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weekly Stats',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _WeeklyStatsScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

class _Run {
  const _Run({
    required this.day,
    required this.title,
    required this.time,
    required this.km,
    required this.duration,
    required this.elevation,
    required this.avgHr,
    required this.type,
  });

  final String day;
  final String title;
  final String time;
  final double km;
  final Duration duration;
  final int elevation;
  final int avgHr;
  final _RunType type;

  Duration get pace =>
      Duration(seconds: (duration.inSeconds / km).round());
}

enum _RunType { easy, tempo, intervals, long }

extension on _RunType {
  String get label => switch (this) {
        _RunType.easy => 'Easy',
        _RunType.tempo => 'Tempo',
        _RunType.intervals => 'Intervals',
        _RunType.long => 'Long run',
      };

  IconData get icon => switch (this) {
        _RunType.easy => Icons.directions_walk_rounded,
        _RunType.tempo => Icons.speed_rounded,
        _RunType.intervals => Icons.timer_outlined,
        _RunType.long => Icons.route_rounded,
      };
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// Distance per weekday (km). 0 = rest day.
const _dailyKm = [6.2, 0.0, 8.4, 5.1, 0.0, 18.6, 4.3];
const _lastWeekKm = 36.9;
const _weeklyGoalKm = 45.0;

const _runs = [
  _Run(
    day: 'Sun, Oct 12',
    title: 'Recovery jog',
    time: '8:10 AM',
    km: 4.3,
    duration: Duration(minutes: 27, seconds: 18),
    elevation: 22,
    avgHr: 132,
    type: _RunType.easy,
  ),
  _Run(
    day: 'Sat, Oct 11',
    title: 'Riverside long run',
    time: '7:02 AM',
    km: 18.6,
    duration: Duration(hours: 1, minutes: 42, seconds: 51),
    elevation: 164,
    avgHr: 148,
    type: _RunType.long,
  ),
  _Run(
    day: 'Thu, Oct 9',
    title: 'Track 6 × 800 m',
    time: '6:15 PM',
    km: 5.1,
    duration: Duration(minutes: 25, seconds: 40),
    elevation: 8,
    avgHr: 161,
    type: _RunType.intervals,
  ),
  _Run(
    day: 'Wed, Oct 8',
    title: 'Tempo loop',
    time: '6:40 AM',
    km: 8.4,
    duration: Duration(minutes: 41, seconds: 12),
    elevation: 71,
    avgHr: 157,
    type: _RunType.tempo,
  ),
  _Run(
    day: 'Mon, Oct 6',
    title: 'Morning easy run',
    time: '6:55 AM',
    km: 6.2,
    duration: Duration(minutes: 36, seconds: 5),
    elevation: 48,
    avgHr: 138,
    type: _RunType.easy,
  ),
];

String _fmtDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
  return '$m:${s.toString().padLeft(2, '0')}';
}

String _fmtPace(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60);
  return '$m:${s.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class _WeeklyStatsScreen extends StatelessWidget {
  const _WeeklyStatsScreen();

  @override
  Widget build(BuildContext context) {
    final totalKm = _runs.fold<double>(0, (a, r) => a + r.km);
    final totalTime =
        _runs.fold<Duration>(Duration.zero, (a, r) => a + r.duration);
    final totalElev = _runs.fold<int>(0, (a, r) => a + r.elevation);
    final avgPace =
        Duration(seconds: (totalTime.inSeconds / totalKm).round());
    final avgHr =
        (_runs.fold<int>(0, (a, r) => a + r.avgHr) / _runs.length).round();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('This Week'),
            actions: [
              IconButton(
                tooltip: 'Share summary',
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Calendar',
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList.list(
              children: [
                const _WeekSwitcher(),
                const SizedBox(height: 16),
                _SummaryCard(totalKm: totalKm, runs: _runs.length),
                const SizedBox(height: 16),
                const _DailyChartCard(),
                const SizedBox(height: 24),
                const _SectionHeader('Highlights'),
                const SizedBox(height: 12),
                _StatGrid(
                  items: [
                    _StatItem(
                      icon: Icons.schedule_rounded,
                      label: 'Moving time',
                      value: _fmtDuration(totalTime),
                    ),
                    _StatItem(
                      icon: Icons.speed_rounded,
                      label: 'Avg pace',
                      value: _fmtPace(avgPace),
                      unit: '/km',
                    ),
                    _StatItem(
                      icon: Icons.terrain_rounded,
                      label: 'Elevation',
                      value: '$totalElev',
                      unit: 'm',
                    ),
                    _StatItem(
                      icon: Icons.favorite_rounded,
                      label: 'Avg heart rate',
                      value: '$avgHr',
                      unit: 'bpm',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionHeader('Activities'),
                const SizedBox(height: 8),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < _runs.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, indent: 72, endIndent: 16),
                        _RunTile(run: _runs[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _WeekSwitcher extends StatelessWidget {
  const _WeekSwitcher();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Previous week',
          onPressed: () {},
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'Oct 6 – Oct 12',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'Week 41 · 2026',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Next week',
          onPressed: null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalKm, required this.runs});

  final double totalKm;
  final int runs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final progress = (totalKm / _weeklyGoalKm).clamp(0.0, 1.0);
    final delta = (totalKm - _lastWeekKm) / _lastWeekKm * 100;
    final up = delta >= 0;
    final remaining = math.max(0, _weeklyGoalKm - totalKm);

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total distance',
          style: theme.textTheme.labelLarge
              ?.copyWith(color: cs.onPrimaryContainer.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: totalKm.toStringAsFixed(1),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onPrimaryContainer,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              TextSpan(
                text: ' km',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Pill(
              icon: up
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              label: '${up ? '+' : ''}${delta.toStringAsFixed(0)}% vs last week',
              color: cs.onPrimaryContainer,
              background: cs.surface.withValues(alpha: 0.55),
            ),
            _Pill(
              icon: Icons.directions_run_rounded,
              label: '$runs runs',
              color: cs.onPrimaryContainer,
              background: cs.surface.withValues(alpha: 0.55),
            ),
          ],
        ),
      ],
    );

    final ring = Semantics(
      label: 'Weekly goal ${(progress * 100).round()} percent complete',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: 104,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                color: cs.primary,
                backgroundColor: cs.surface.withValues(alpha: 0.6),
              ),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'of goal',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                          ),
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

    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final scale = MediaQuery.textScalerOf(context).scale(1);
                final stack = constraints.maxWidth < 340 || scale > 1.3;
                if (stack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [textBlock, const SizedBox(height: 16), ring],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: textBlock),
                    const SizedBox(width: 16),
                    ring,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              remaining > 0
                  ? '${remaining.toStringAsFixed(1)} km to your ${_weeklyGoalKm.toStringAsFixed(0)} km goal'
                  : 'Weekly goal reached. Nice work!',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChartCard extends StatelessWidget {
  const _DailyChartCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final maxKm = _dailyKm.reduce(math.max);
    final best = _dailyKm.indexOf(maxKm);
    // Keep axis labels legible but bounded so seven columns always fit.
    final labelScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1, maxScaleFactor: 1.4);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  'Daily distance',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '5 of 7 days active',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 20),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: labelScaler),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: _Bar(
                        day: _weekdays[i],
                        km: _dailyKm[i],
                        fraction: maxKm == 0 ? 0 : _dailyKm[i] / maxKm,
                        highlighted: i == best,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.day,
    required this.km,
    required this.fraction,
    required this.highlighted,
  });

  final String day;
  final double km;
  final double fraction;
  final bool highlighted;

  static const double _trackHeight = 140;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final rest = km == 0;
    final barColor = highlighted ? cs.primary : cs.primary.withValues(alpha: 0.45);

    return Semantics(
      label: rest ? '$day, rest day' : '$day, ${km.toStringAsFixed(1)} kilometers',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  rest ? '–' : km.toStringAsFixed(1),
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: highlighted ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: _trackHeight,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 22,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 22,
                      height: rest ? 0 : math.max(8, _trackHeight * fraction),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  day,
                  maxLines: 1,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: highlighted ? cs.onSurface : cs.onSurfaceVariant,
                    fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? unit;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.items});
  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final columns = (constraints.maxWidth < 360 || scale > 1.5) ? 1 : 2;
        const gap = 12.0;
        final width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(width: width, child: _StatTile(item: item)),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.item});
  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.icon, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.label,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: item.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (item.unit != null)
                    TextSpan(
                      text: ' ${item.unit}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunTile extends StatelessWidget {
  const _RunTile({required this.run});
  final _Run run;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted =
        theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(run.type.icon,
                  size: 22, color: cs.onSecondaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    run.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text('${run.day} · ${run.time} · ${run.type.label}',
                      style: muted),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _Metric(
                          value: run.km.toStringAsFixed(1), unit: 'km'),
                      _Metric(value: _fmtDuration(run.duration), unit: ''),
                      _Metric(value: _fmtPace(run.pace), unit: '/km'),
                      _Metric(value: '${run.avgHr}', unit: 'bpm'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.unit});
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (unit.isNotEmpty)
            TextSpan(
              text: ' $unit',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
