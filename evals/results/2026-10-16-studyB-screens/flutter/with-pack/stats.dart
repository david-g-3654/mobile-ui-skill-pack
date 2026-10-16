import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_eval/pack04/theme.dart';
import 'package:fl_eval/pack04/components.dart';

class StatsEvalApp extends StatelessWidget {
  const StatsEvalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: quietTheme(Brightness.light),
    darkTheme: quietTheme(Brightness.dark),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home: const _RunningStatsScreen(),
  );
}

class _Run {
  const _Run(this.name, this.day, this.when, this.distance, this.seconds);

  final String name;
  final int day;
  final String when;
  final double distance;
  final int seconds;

  String get duration =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _Week {
  const _Week(this.dates, this.comparison, this.runs, this.isCurrent);

  final String dates;
  final String comparison;
  final List<_Run> runs;
  final bool isCurrent;

  double get distance => runs.fold(0, (total, run) => total + run.distance);
  int get seconds => runs.fold(0, (total, run) => total + run.seconds);
  double distanceOn(int day) => runs
      .where((run) => run.day == day)
      .fold(0, (total, run) => total + run.distance);

  String get time => '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
  String get pace {
    final paceSeconds = (seconds / distance).round();
    return '${paceSeconds ~/ 60}′${(paceSeconds % 60).toString().padLeft(2, '0')}″';
  }
}

const _weeks = [
  _Week('12–18 Oct 2026', '↑ 3.2 km vs. last week by Friday', [
    _Run('River loop', 4, 'Today · 6:42 am', 6.4, 2112),
    _Run(
      'An easy one around the neighborhood',
      3,
      'Thu, 15 Oct · 7:10 am',
      4.8,
      1584,
    ),
    _Run('Park tempo', 2, 'Wed, 14 Oct · 6:35 am', 8.4, 2621),
    _Run('Monday miles', 0, 'Mon, 12 Oct · 6:50 am', 5.2, 1716),
  ], true),
  _Week('5–11 Oct 2026', '↑ 2.6 km vs. 28 Sep–4 Oct', [
    _Run('Sunday long run', 6, 'Sun, 11 Oct · 7:05 am', 9.6, 3254),
    _Run('Riverside recovery', 4, 'Fri, 9 Oct · 6:55 am', 5.0, 1625),
    _Run('After-work loop', 3, 'Thu, 8 Oct · 5:42 pm', 4.6, 1518),
    _Run('Steady through the park', 2, 'Wed, 7 Oct · 6:30 am', 7.2, 2290),
    _Run('A fresh start', 0, 'Mon, 5 Oct · 7:12 am', 4.8, 1584),
  ], false),
];

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _fullDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class _RunningStatsScreen extends StatefulWidget {
  const _RunningStatsScreen();

  @override
  State<_RunningStatsScreen> createState() => _RunningStatsScreenState();
}

class _RunningStatsScreenState extends State<_RunningStatsScreen> {
  int _selectedWeek = 0;

  void _showDistances(_Week week) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
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
            spacing: QSpace.md,
            children: [
              Semantics(
                header: true,
                child: Text('Daily distances', style: context.qText.titleLarge),
              ),
              Text(week.dates, style: context.qText.bodyMedium),
              for (var day = 0; day < _days.length; day++)
                MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: QSpace.xs),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: QSpace.md,
                      runSpacing: QSpace.xxs,
                      children: [
                        Text(_fullDays[day], style: context.qText.bodyLarge),
                        Text(
                          week.isCurrent && day > 4
                              ? 'Upcoming'
                              : week.distanceOn(day) == 0
                              ? 'Rest day'
                              : '${week.distanceOn(day).toStringAsFixed(1)} km',
                          style: context.qText.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final week = _weeks[_selectedWeek];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(
              title: Text('Running stats'),
              centerTitle: false,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                QSpace.margin,
                QSpace.xs,
                QSpace.margin,
                QSpace.xxl,
              ),
              sliver: SliverList.list(
                children: [
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('This week')),
                      ButtonSegment(value: 1, label: Text('Last week')),
                    ],
                    selected: {_selectedWeek},
                    onSelectionChanged: (selection) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedWeek = selection.first);
                    },
                    style: ButtonStyle(
                      minimumSize: const WidgetStatePropertyAll(
                        Size(0, QMetrics.minTap),
                      ),
                      textStyle: WidgetStatePropertyAll(
                        context.qText.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: QSpace.xxl),
                  Text(week.dates, style: context.qText.bodyMedium),
                  const SizedBox(height: QSpace.sm),
                  Semantics(
                    label: 'Total running distance',
                    child: QDisplayScale(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: week.distance),
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : QMotion.medium,
                          curve: QMotion.curve,
                          builder: (context, value, child) => Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: value.toStringAsFixed(1),
                                  style: context.qText.displayLarge,
                                ),
                                TextSpan(
                                  text: ' km',
                                  style: context.qText.titleLarge?.copyWith(
                                    color: context.q.ink2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: QSpace.xs),
                  Text(week.comparison, style: context.qText.bodyMedium),
                  const SizedBox(height: QSpace.sm),
                  QBarChart(
                    height: 160,
                    highlighted: week.isCurrent ? 4 : 6,
                    bars: [
                      for (var day = 0; day < _days.length; day++)
                        QBar(
                          label: _days[day],
                          shortLabel: _days[day][0],
                          value: week.distanceOn(day),
                          spokenValue: week.isCurrent && day > 4
                              ? 'upcoming'
                              : '${week.distanceOn(day).toStringAsFixed(1)} kilometers',
                        ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showDistances(week),
                      child: Text(
                        'Daily distances',
                        style: context.qText.bodySmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: QSpace.xs),
                  QMetricRow(
                    items: [
                      (week.time, 'Running time'),
                      ('${week.pace} /km', 'Average pace'),
                      ('${week.runs.length}', 'Runs'),
                    ],
                  ),
                  const SizedBox(height: QSpace.xxl),
                  Semantics(
                    header: true,
                    child: Text('Run log', style: context.qText.titleLarge),
                  ),
                  const SizedBox(height: QSpace.xs),
                  if (week.runs.isEmpty)
                    const QEmptyState(
                      icon: Icons.directions_run_rounded,
                      title: 'No runs this week',
                      message: 'Your recorded runs will appear here.',
                    ),
                  for (final run in week.runs) ...[
                    _RunRow(run: run),
                    if (run != week.runs.last) const Divider(height: 1),
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

class _RunRow extends StatelessWidget {
  const _RunRow({required this.run});

  final _Run run;

  @override
  Widget build(BuildContext context) {
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: QSpace.xxs,
      children: [
        Text(run.name, style: context.qText.titleMedium),
        Text('${run.when} · ${run.duration}', style: context.qText.bodyMedium),
      ],
    );
    final distance = Text(
      '${run.distance.toStringAsFixed(1)} km',
      style: context.qText.titleMedium?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: QSpace.md),
        child: MediaQuery.textScalerOf(context).scale(16) > 20
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: QSpace.xs,
                children: [details, distance],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: QSpace.md,
                children: [
                  Expanded(child: details),
                  distance,
                ],
              ),
      ),
    );
  }
}
