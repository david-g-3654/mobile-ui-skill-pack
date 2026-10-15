// Stats archetype. Job: see how this week's running is going.
// Focal: the week's distance (hero). Primary action: none — the week stepper is the main control.
// Cut: per-day cards, a second chart, a 2×2 stat grid, a Day/Month/Year switch (a weekly screen needs only weeks).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack04/components.dart';
import 'package:fl_eval/pack04/theme.dart';

class StatsEvalApp extends StatelessWidget {
  const StatsEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Running',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _WeeklyRunningScreen(),
    );
  }
}

// ── Sample data (today: Thu, Oct 15) ────────────────────────────────

class _Run {
  const _Run({required this.weekday, required this.date, required this.kind, required this.km, required this.seconds});

  /// 0 = Monday … 6 = Sunday.
  final int weekday;
  final String date;
  final String kind;
  final double km;
  final int seconds;
}

class _Week {
  const _Week({required this.title, required this.range, required this.runs, this.daysElapsed = 7});

  final String title;
  final String range;
  final List<_Run> runs;

  /// Days of the week that have happened (7 for past weeks). Used to compare like with like mid-week.
  final int daysElapsed;

  double get km => runs.fold(0, (s, r) => s + r.km);
  int get seconds => runs.fold(0, (s, r) => s + r.seconds);
  double kmThrough(int days) => runs.where((r) => r.weekday < days).fold(0, (s, r) => s + r.km);
  List<double> get perDay => [for (var d = 0; d < 7; d++) runs.where((r) => r.weekday == d).fold(0, (s, r) => s + r.km)];
}

// Index 0 is the current week; higher indices go back in time.
const _weeks = [
  _Week(title: 'This week', range: 'Oct 12–18', daysElapsed: 4, runs: [
    _Run(weekday: 3, date: 'Thu, Oct 15', kind: 'Tempo', km: 7.0, seconds: 39 * 60 + 12),
    _Run(weekday: 2, date: 'Wed, Oct 14', kind: 'Easy run', km: 8.4, seconds: 49 * 60 + 30),
    _Run(weekday: 0, date: 'Mon, Oct 12', kind: 'Easy run', km: 6.2, seconds: 36 * 60 + 5),
  ]),
  _Week(title: 'Last week', range: 'Oct 5–11', runs: [
    _Run(weekday: 6, date: 'Sun, Oct 11', kind: 'Recovery', km: 4.0, seconds: 25 * 60 + 20),
    _Run(weekday: 5, date: 'Sat, Oct 10', kind: 'Long run', km: 14.5, seconds: 86 * 60 + 40),
    _Run(weekday: 3, date: 'Thu, Oct 8', kind: 'Intervals', km: 7.2, seconds: 40 * 60 + 5),
    _Run(weekday: 2, date: 'Wed, Oct 7', kind: 'Easy run', km: 7.1, seconds: 41 * 60 + 52),
    _Run(weekday: 0, date: 'Mon, Oct 5', kind: 'Easy run', km: 5.0, seconds: 29 * 60 + 10),
  ]),
  _Week(title: 'Sep 28 – Oct 4', range: '2 weeks ago', runs: [
    _Run(weekday: 6, date: 'Sun, Oct 4', kind: 'Recovery', km: 5.0, seconds: 30 * 60 + 15),
    _Run(weekday: 5, date: 'Sat, Oct 3', kind: 'Long run', km: 12.4, seconds: 73 * 60 + 30),
    _Run(weekday: 3, date: 'Thu, Oct 1', kind: 'Tempo', km: 8.0, seconds: 45 * 60 + 44),
    _Run(weekday: 1, date: 'Tue, Sep 29', kind: 'Easy run', km: 6.0, seconds: 35 * 60 + 48),
  ]),
  _Week(title: 'Sep 21–27', range: '3 weeks ago', runs: []),
];

const _weeklyGoalKm = 30.0;
const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const _spokenDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

String _km(double v) => v.toStringAsFixed(1);

String _duration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$m:$ss';
}

String _pace(int seconds, double km) {
  if (km <= 0) return '–';
  final perKm = (seconds / km).round();
  return '${perKm ~/ 60}\'${(perKm % 60).toString().padLeft(2, '0')}"';
}

// ── Screen ──────────────────────────────────────────────────────────

class _WeeklyRunningScreen extends StatefulWidget {
  const _WeeklyRunningScreen();

  @override
  State<_WeeklyRunningScreen> createState() => _WeeklyRunningScreenState();
}

class _WeeklyRunningScreenState extends State<_WeeklyRunningScreen> {
  int _index = 0;

  void _step(int delta) {
    HapticFeedback.selectionClick();
    setState(() => _index += delta);
  }

  @override
  Widget build(BuildContext context) {
    final week = _weeks[_index];
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text('Running')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(QSpace.margin, 0, QSpace.margin, QSpace.xxl),
            sliver: SliverList.list(children: [
              _WeekStepper(
                week: week,
                canGoBack: _index < _weeks.length - 1,
                canGoForward: _index > 0,
                onBack: () => _step(1),
                onForward: () => _step(-1),
              ),
              const SizedBox(height: QSpace.md),
              AnimatedSwitcher(
                duration: reduceMotion ? Duration.zero : QMotion.medium,
                switchInCurve: QMotion.curve,
                switchOutCurve: QMotion.curve,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topLeft,
                  children: [...previous, ?current],
                ),
                child: _WeekSummary(key: ValueKey(_index), week: week, previous: _index + 1 < _weeks.length ? _weeks[_index + 1] : null),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _WeekStepper extends StatelessWidget {
  const _WeekStepper({
    required this.week,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final _Week week;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous week',
          onPressed: canGoBack ? onBack : null,
          icon: const Icon(Icons.chevron_left_rounded),
          color: q.ink,
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: week.title, style: context.qText.titleMedium),
                TextSpan(text: '  ·  ${week.range}', style: context.qText.bodyMedium),
              ]),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next week',
          onPressed: canGoForward ? onForward : null,
          icon: const Icon(Icons.chevron_right_rounded),
          color: q.ink,
        ),
      ],
    );
  }
}

class _WeekSummary extends StatelessWidget {
  const _WeekSummary({super.key, required this.week, required this.previous});

  final _Week week;
  final _Week? previous;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final isCurrent = week.daysElapsed < 7;
    final empty = week.runs.isEmpty;

    // Compare like with like: mid-week, against the same days of last week.
    QDelta? delta;
    String? note;
    if (empty) {
      note = 'No runs logged';
    } else if (previous == null || previous!.km == 0) {
      note = 'Back after a rest week';
    } else {
      final before = previous!.kmThrough(week.daysElapsed);
      if (before > 0) {
        final change = ((week.km - before) / before * 100).round();
        delta = QDelta(
          '${change.abs()}% vs ${isCurrent ? 'this time last week' : 'the week before'}',
          up: change >= 0,
        );
      }
    }
    final goalNote = '${(week.km / _weeklyGoalKm * 100).round()}% of ${_weeklyGoalKm.round()} km goal';

    final perDay = week.perDay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QHeroMetric(
          label: 'Distance',
          value: empty ? '0' : _km(week.km),
          suffix: ' km',
          delta: delta,
          context: note ?? goalNote,
        ),
        const SizedBox(height: QSpace.xl),
        Stack(
          children: [
            QBarChart(
              height: 180,
              highlighted: isCurrent ? week.daysElapsed - 1 : null,
              bars: [
                for (var d = 0; d < 7; d++)
                  QBar(
                    label: _dayNames[d],
                    shortLabel: _dayLetters[d],
                    value: perDay[d],
                    spokenValue: '${_spokenDays[d]} ${_km(perDay[d])} kilometres',
                  ),
              ],
            ),
            if (empty)
              Positioned.fill(
                bottom: 32,
                child: Center(
                  child: Text('No runs this week', style: context.qText.bodyMedium, textAlign: TextAlign.center),
                ),
              ),
          ],
        ),
        const SizedBox(height: QSpace.xl),
        QMetricRow(items: [
          (empty ? '0:00' : _duration(week.seconds), 'Time'),
          (_pace(week.seconds, week.km), 'Avg pace /km'),
          ('${week.runs.length}', week.runs.length == 1 ? 'Run' : 'Runs'),
        ]),
        const SizedBox(height: QSpace.xxl),
        QGroupedSection(
          header: 'Runs',
          children: [
            if (empty)
              const QListRow(
                title: 'Nothing logged',
                subtitle: 'Runs you record or sync from your watch show up here.',
              )
            else
              for (final run in week.runs)
                QListRow(
                  title: run.date,
                  subtitle: '${run.kind} · ${_pace(run.seconds, run.km)} /km · ${_duration(run.seconds)}',
                  value: '${_km(run.km)} km',
                ),
          ],
        ),
        if (isCurrent) ...[
          const SizedBox(height: QSpace.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: QSpace.md),
            child: Text(
              '${_km((_weeklyGoalKm - week.km).clamp(0, _weeklyGoalKm))} km to go with ${7 - week.daysElapsed} days left.',
              style: context.qText.bodySmall?.copyWith(color: q.ink2),
            ),
          ),
        ],
      ],
    );
  }
}
