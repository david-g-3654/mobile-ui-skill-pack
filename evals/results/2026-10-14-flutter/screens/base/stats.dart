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
        centerTitle: false,
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
    required this.date,
    required this.title,
    required this.km,
    required this.duration,
    required this.avgHr,
    required this.type,
  });

  final String day;
  final String date;
  final String title;
  final double km;
  final Duration duration;
  final int avgHr;
  final String type;

  Duration get pacePerKm =>
      Duration(seconds: (duration.inSeconds / km).round());
}

class _DayTotal {
  const _DayTotal(this.label, this.km, {this.isToday = false});
  final String label;
  final double km;
  final bool isToday;
}

const _days = <_DayTotal>[
  _DayTotal('M', 6.2),
  _DayTotal('T', 0),
  _DayTotal('W', 10.4),
  _DayTotal('T', 5.0),
  _DayTotal('F', 0),
  _DayTotal('S', 18.6),
  _DayTotal('S', 4.1, isToday: true),
];

const _runs = <_Run>[
  _Run(
    day: 'Sun',
    date: 'Oct 12',
    title: 'Recovery jog',
    km: 4.1,
    duration: Duration(minutes: 26, seconds: 9),
    avgHr: 132,
    type: 'Easy',
  ),
  _Run(
    day: 'Sat',
    date: 'Oct 11',
    title: 'Long run · Riverside loop',
    km: 18.6,
    duration: Duration(hours: 1, minutes: 41, seconds: 48),
    avgHr: 151,
    type: 'Long',
  ),
  _Run(
    day: 'Thu',
    date: 'Oct 9',
    title: 'Easy morning run',
    km: 5.0,
    duration: Duration(minutes: 29, seconds: 55),
    avgHr: 138,
    type: 'Easy',
  ),
  _Run(
    day: 'Wed',
    date: 'Oct 8',
    title: '6 × 800 m intervals',
    km: 10.4,
    duration: Duration(minutes: 52, seconds: 30),
    avgHr: 163,
    type: 'Workout',
  ),
  _Run(
    day: 'Mon',
    date: 'Oct 6',
    title: 'Tempo run',
    km: 6.2,
    duration: Duration(minutes: 31, seconds: 2),
    avgHr: 158,
    type: 'Tempo',
  ),
];

const double _weeklyGoalKm = 50;
const double _lastWeekKm = 38.9;
const Duration _lastWeekAvgPace = Duration(minutes: 5, seconds: 41);

String _fmtPace(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

String _fmtDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
  return '${m}m ${s.toString().padLeft(2, '0')}s';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class _WeeklyStatsScreen extends StatelessWidget {
  const _WeeklyStatsScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalKm = _runs.fold<double>(0, (a, r) => a + r.km);
    final totalTime =
        _runs.fold<Duration>(Duration.zero, (a, r) => a + r.duration);
    final avgPace =
        Duration(seconds: (totalTime.inSeconds / totalKm).round());
    final longest = _runs.reduce((a, b) => a.km >= b.km ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This week', style: theme.textTheme.titleLarge),
            Text(
              'Oct 6 – Oct 12',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Previous week',
            icon: const Icon(Icons.chevron_left),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Next week',
            icon: const Icon(Icons.chevron_right),
            onPressed: null,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _SummaryCard(totalKm: totalKm),
            const SizedBox(height: 16),
            _StatGrid(
              tiles: [
                _StatTileData(
                  icon: Icons.timer_outlined,
                  label: 'Moving time',
                  value: _fmtDuration(totalTime),
                ),
                _StatTileData(
                  icon: Icons.speed,
                  label: 'Avg pace',
                  value: '${_fmtPace(avgPace)} /km',
                  delta: avgPace < _lastWeekAvgPace
                      ? '${_lastWeekAvgPace.inSeconds - avgPace.inSeconds}s faster'
                      : '${avgPace.inSeconds - _lastWeekAvgPace.inSeconds}s slower',
                  positive: avgPace < _lastWeekAvgPace,
                ),
                _StatTileData(
                  icon: Icons.directions_run,
                  label: 'Runs',
                  value: '${_runs.length}',
                ),
                _StatTileData(
                  icon: Icons.emoji_events_outlined,
                  label: 'Longest run',
                  value: '${longest.km.toStringAsFixed(1)} km',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _DailyChartCard(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Runs',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < _runs.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 72,
                        color: theme.colorScheme.outlineVariant,
                      ),
                    _RunTile(run: _runs[i]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totalKm});
  final double totalKm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = (totalKm / _weeklyGoalKm).clamp(0.0, 1.0);
    final diff = totalKm - _lastWeekKm;
    final pct = (diff / _lastWeekKm * 100).round();
    final remaining = (_weeklyGoalKm - totalKm).clamp(0, _weeklyGoalKm);

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total distance',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 6,
              children: [
                Text(
                  totalKm.toStringAsFixed(1),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'km',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: scheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        diff >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: scheme.onPrimary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$pct%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'vs ${_lastWeekKm.toStringAsFixed(1)} km last week',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Semantics(
              label: 'Weekly goal progress',
              value: '${(progress * 100).round()} percent',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor:
                      scheme.onPrimaryContainer.withValues(alpha: 0.15),
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 2,
              children: [
                Text(
                  'Goal ${_weeklyGoalKm.toStringAsFixed(0)} km · ${(progress * 100).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${remaining.toStringAsFixed(1)} km to go',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTileData {
  const _StatTileData({
    required this.icon,
    required this.label,
    required this.value,
    this.delta,
    this.positive = true,
  });
  final IconData icon;
  final String label;
  final String value;
  final String? delta;
  final bool positive;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.tiles});
  final List<_StatTileData> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final columns = textScale > 1.6 || constraints.maxWidth < 300 ? 1 : 2;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in tiles)
              SizedBox(width: width, child: _StatTile(data: t)),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});
  final _StatTileData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final deltaColor =
        data.positive ? const Color(0xFF2E9E5B) : scheme.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(data.icon, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data.label,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (data.delta != null) ...[
              const SizedBox(height: 2),
              Text(
                data.delta!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: deltaColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
    final scheme = theme.colorScheme;
    final maxKm = _days.map((d) => d.km).reduce((a, b) => a > b ? a : b);
    const chartHeight = 140.0;
    const fullNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily distance',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '5 of 7 days active',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < _days.length; i++)
                  Expanded(
                    child: Semantics(
                      label: '${fullNames[i]}: '
                          '${_days[i].km == 0 ? 'rest day' : '${_days[i].km.toStringAsFixed(1)} kilometers'}',
                      excludeSemantics: true,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 18,
                            child: FittedBox(
                              child: Text(
                                _days[i].km == 0
                                    ? '–'
                                    : _days[i].km.toStringAsFixed(
                                        _days[i].km >= 10 ? 0 : 1),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: chartHeight,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                widthFactor: 0.62,
                                heightFactor: _days[i].km == 0
                                    ? 0.03
                                    : (_days[i].km / maxKm).clamp(0.06, 1.0),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: _days[i].km == 0
                                        ? scheme.outlineVariant
                                        : _days[i].km == maxKm
                                            ? scheme.primary
                                            : scheme.primary
                                                .withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 22,
                            child: FittedBox(
                              child: Text(
                                _days[i].label,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: _days[i].isToday
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant,
                                  fontWeight: _days[i].isToday
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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

  Color _typeColor(ColorScheme scheme) {
    switch (run.type) {
      case 'Long':
        return scheme.primary;
      case 'Workout':
        return scheme.tertiary;
      case 'Tempo':
        return scheme.secondary;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _typeColor(scheme);
    final metaStyle =
        theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  FittedBox(
                    child: Text(
                      run.day,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      run.date.split(' ').last,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    run.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 2,
                    children: [
                      Text('${run.km.toStringAsFixed(1)} km',
                          style: metaStyle?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w600)),
                      Text('${_fmtPace(run.pacePerKm)} /km', style: metaStyle),
                      Text(_fmtDuration(run.duration), style: metaStyle),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite,
                              size: 12, color: scheme.error),
                          const SizedBox(width: 3),
                          Text('${run.avgHr} bpm', style: metaStyle),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: color.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                run.type,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
