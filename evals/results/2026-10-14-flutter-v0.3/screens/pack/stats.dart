// Stats archetype. Job: see how this week's running is going.
// Focal: the week's distance (hero). Primary action: none — the week stepper and
// tapping a day are the interactions. Cut: month/year views, pace chart, badges.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

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
      home: const _WeeklyStatsScreen(),
    );
  }
}

// ── Sample data ─────────────────────────────────────────────────────

class _Run {
  const _Run(this.date, this.name, this.miles, this.duration);
  final DateTime date;
  final String name;
  final double miles;
  final Duration duration;
}

class _Week {
  const _Week(this.start, this.runs);
  final DateTime start; // Monday
  final List<_Run> runs;

  DateTime get end => start.add(const Duration(days: 6));
  double get miles => runs.fold(0, (s, r) => s + r.miles);
  Duration get time => runs.fold(Duration.zero, (s, r) => s + r.duration);
  double milesOn(int dayIndex) =>
      runs.where((r) => r.date.weekday - 1 == dayIndex).fold(0, (s, r) => s + r.miles);
  double milesThrough(int dayIndex) =>
      runs.where((r) => r.date.weekday - 1 <= dayIndex).fold(0, (s, r) => s + r.miles);
}

final DateTime _today = DateTime(2026, 10, 14); // Wednesday

Duration _d(int h, int m, int s) => Duration(hours: h, minutes: m, seconds: s);

/// Newest first.
final List<_Week> _weeks = [
  _Week(DateTime(2026, 10, 12), [
    _Run(DateTime(2026, 10, 14), 'Tempo run', 6.1, _d(0, 52, 28)),
    _Run(DateTime(2026, 10, 12), 'Easy run', 4.2, _d(0, 38, 51)),
  ]),
  _Week(DateTime(2026, 10, 5), [
    _Run(DateTime(2026, 10, 11), 'Shakeout', 3.5, _d(0, 33, 5)),
    _Run(DateTime(2026, 10, 10), 'Long run along the river', 10.2, _d(1, 36, 12)),
    _Run(DateTime(2026, 10, 8), 'Tempo run', 6.4, _d(0, 55, 31)),
    _Run(DateTime(2026, 10, 6), 'Hill repeats', 5.0, _d(0, 46, 40)),
    _Run(DateTime(2026, 10, 5), 'Recovery jog', 3.1, _d(0, 30, 2)),
  ]),
  _Week(DateTime(2026, 9, 28), const []),
];

const double _dailyGoal = 5;

// ── Formatting ──────────────────────────────────────────────────────

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _dayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

String _md(DateTime d) => '${_months[d.month - 1]} ${d.day}';
String _dayDate(DateTime d) => '${_weekdays[d.weekday - 1]}, ${_md(d)}';
String _range(_Week w) =>
    w.start.month == w.end.month ? '${_md(w.start)}–${w.end.day}' : '${_md(w.start)}–${_md(w.end)}';
String _mi(double v) => v.toStringAsFixed(1);

String _clock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '${d.inMinutes}:$s';
}

String _pace(Duration time, double miles) {
  if (miles <= 0) return '–';
  final secs = (time.inSeconds / miles).round();
  return "${secs ~/ 60}'${(secs % 60).toString().padLeft(2, '0')}\"";
}

// ── Screen ──────────────────────────────────────────────────────────

class _WeeklyStatsScreen extends StatefulWidget {
  const _WeeklyStatsScreen();

  @override
  State<_WeeklyStatsScreen> createState() => _WeeklyStatsScreenState();
}

class _WeeklyStatsScreenState extends State<_WeeklyStatsScreen> {
  int _weekIndex = 0; // 0 = this week
  int? _selectedDay;
  bool _loading = false;

  _Week get _week => _weeks[_weekIndex];
  bool get _isCurrent => _weekIndex == 0;

  /// Index of the last day with data: today for the current week, Sunday otherwise.
  int get _lastDay => _isCurrent ? _today.weekday - 1 : 6;

  void _step(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _weekIndex = (_weekIndex + delta).clamp(0, _weeks.length - 1);
      _selectedDay = null;
    });
  }

  void _toggleDay(int day) {
    HapticFeedback.selectionClick();
    setState(() => _selectedDay = _selectedDay == day ? null : day);
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverAppBar.large(title: Text('Running')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, Space.xxl),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WeekStepper(
                      title: switch (_weekIndex) { 0 => 'This week', 1 => 'Last week', _ => 'Week of ${_md(_week.start)}' },
                      range: _range(_week),
                      onPrevious: _weekIndex < _weeks.length - 1 ? () => _step(1) : null,
                      onNext: _weekIndex > 0 ? () => _step(-1) : null,
                    ),
                    const SizedBox(height: Space.xl),
                    if (_loading) const _StatsSkeleton() else ..._content(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context) {
    final week = _week;
    final sel = _selectedDay;
    final animate = !MediaQuery.disableAnimationsOf(context);

    // Hero: the selected day, or the week total.
    final Widget hero;
    if (sel != null) {
      final dayRuns = week.runs.where((r) => r.date.weekday - 1 == sel).toList();
      final day = week.start.add(Duration(days: sel));
      hero = HeroMetric(
        label: _dayDate(day),
        value: _mi(week.milesOn(sel)),
        suffix: ' mi',
        context: dayRuns.map((r) => '${r.name} · ${_clock(r.duration)}').join(', '),
      );
    } else {
      Delta? delta;
      String? note;
      if (_isCurrent) {
        // Compare like with like: Mon–today vs Mon–same weekday last week.
        final before = _weeks[1].milesThrough(_lastDay);
        if (before > 0) {
          final pct = ((week.miles - before) / before * 100).round();
          delta = Delta('${pct.abs()}% vs this time last week', up: pct >= 0);
        }
        final left = 6 - _lastDay;
        note = '$left days to go';
      } else if (_weekIndex + 1 < _weeks.length && _weeks[_weekIndex + 1].miles > 0) {
        final before = _weeks[_weekIndex + 1].miles;
        final pct = ((week.miles - before) / before * 100).round();
        delta = Delta('${pct.abs()}% vs previous week', up: pct >= 0);
      } else if (week.runs.isEmpty) {
        note = 'Rest week';
      }
      hero = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.xs,
        children: [
          HeroMetric(label: 'Distance', value: _mi(week.miles), suffix: ' mi', context: note),
          if (delta != null) _DeltaLine(delta),
        ],
      );
    }

    final values = [for (var i = 0; i < 7; i++) i > _lastDay ? null : week.milesOn(i)];
    final highlight = sel ?? (_isCurrent ? _lastDay : null);

    return [
      AnimatedSwitcher(
        duration: animate ? Motion.medium : Duration.zero,
        switchInCurve: Motion.curve,
        layoutBuilder: (current, previous) =>
            Stack(alignment: Alignment.topLeft, children: [...previous, ?current]),
        child: KeyedSubtree(key: ValueKey('$_weekIndex-$sel'), child: hero),
      ),
      const SizedBox(height: Space.xl),
      _WeekChart(
        values: values,
        highlight: highlight,
        selected: sel,
        isCurrentWeek: _isCurrent,
        todayIndex: _today.weekday - 1,
        emptyMessage: week.runs.isEmpty ? 'No runs this week' : null,
        onTapDay: _toggleDay,
      ),
      const SizedBox(height: Space.xl),
      MetricRow(items: [
        (_clock(week.time), 'Time'),
        (_pace(week.time, week.miles), 'Avg pace per mile'),
        ('${week.runs.length}', week.runs.length == 1 ? 'Run' : 'Runs'),
      ]),
      const SizedBox(height: Space.xxl),
      GroupedSection(
        header: 'Runs',
        children: week.runs.isEmpty
            ? [
                ListRow(
                  title: 'Nothing logged ${_range(week)}',
                  subtitle: 'Runs you record or sync from your watch show up here.',
                ),
              ]
            : [
                for (final r in week.runs)
                  ListRow(
                    title: r.name,
                    subtitle: '${_dayDate(r.date)} · ${_clock(r.duration)} · ${_pace(r.duration, r.miles)} /mi',
                    value: '${_mi(r.miles)} mi',
                    onTap: () {},
                  ),
              ],
      ),
    ];
  }
}

// ── Delta (wraps at large text, unlike a fixed row) ────────────────

class _DeltaLine extends StatelessWidget {
  const _DeltaLine(this.delta);

  final Delta delta;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final color = delta.up == delta.upIsGood ? q.positive : q.negative;
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.xxs,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(delta.up ? Icons.north_east_rounded : Icons.south_east_rounded, size: 16, color: color),
          ),
          Flexible(
            child: Text(
              '${delta.up ? 'Up' : 'Down'} ${delta.text}',
              style: context.t.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Week stepper ────────────────────────────────────────────────────

class _WeekStepper extends StatelessWidget {
  const _WeekStepper({required this.title, required this.range, this.onPrevious, this.onNext});

  final String title;
  final String range;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous week',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: MergeSemantics(
            child: Column(
              spacing: 2,
              children: [
                Text(title, style: context.t.titleMedium, textAlign: TextAlign.center),
                Text(range, style: context.t.bodyMedium, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next week',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

// ── Chart ───────────────────────────────────────────────────────────

class _WeekChart extends StatelessWidget {
  const _WeekChart({
    required this.values,
    required this.highlight,
    required this.selected,
    required this.isCurrentWeek,
    required this.todayIndex,
    required this.emptyMessage,
    required this.onTapDay,
  });

  /// Miles per day, Monday first. `null` = a day that hasn't happened yet.
  final List<double?> values;
  final int? highlight;
  final int? selected;
  final bool isCurrentWeek;
  final int todayIndex;
  final String? emptyMessage;
  final ValueChanged<int> onTapDay;

  static const double _height = 180;

  String _summary() {
    final parts = <String>[];
    for (var i = 0; i < 7; i++) {
      final v = values[i];
      parts.add(v == null ? '${_weekdays[i]} upcoming' : '${_weekdays[i]} ${_mi(v)}');
    }
    return 'Miles per day, goal ${_dailyGoal.toStringAsFixed(0)} miles. ${parts.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5);
    return Semantics(
      label: _summary(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.xs,
        children: [
          SizedBox(
            height: _height,
            child: LayoutBuilder(
              builder: (context, box) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) {
                  final i = (d.localPosition.dx / (box.maxWidth / 7)).floor().clamp(0, 6);
                  final v = values[i];
                  if (v != null && v > 0) onTapDay(i);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _BarsPainter(
                        values: values,
                        highlight: highlight,
                        goal: _dailyGoal,
                        goalLabel: 'Goal ${_dailyGoal.toStringAsFixed(0)} mi',
                        labelStyle: context.t.bodySmall!,
                        textScaler: scaler,
                        bar: q.ink.withValues(alpha: 0.85),
                        accent: q.accent,
                        stub: q.surface2,
                        guide: q.ink3,
                        baseline: q.hairline,
                      ),
                    ),
                    if (emptyMessage != null)
                      Center(child: Text(emptyMessage!, style: context.t.bodyMedium)),
                  ],
                ),
              ),
            ),
          ),
          ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Text(
                      _dayInitials[i],
                      textAlign: TextAlign.center,
                      style: (isCurrentWeek && i == todayIndex) || selected == i
                          ? context.t.bodySmall?.copyWith(color: q.ink, fontWeight: FontWeight.w600)
                          : context.t.bodySmall,
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

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.values,
    required this.highlight,
    required this.goal,
    required this.goalLabel,
    required this.labelStyle,
    required this.textScaler,
    required this.bar,
    required this.accent,
    required this.stub,
    required this.guide,
    required this.baseline,
  });

  final List<double?> values;
  final int? highlight;
  final double goal;
  final String goalLabel;
  final TextStyle labelStyle;
  final TextScaler textScaler;
  final Color bar, accent, stub, guide, baseline;

  @override
  void paint(Canvas canvas, Size size) {
    final label = TextPainter(
      text: TextSpan(text: goalLabel, style: labelStyle),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();

    final top = label.height + 4;
    final chartH = size.height - top;
    final maxV = math.max(goal * 1.15, values.fold<double>(0, (m, v) => math.max(m, v ?? 0)) * 1.05);
    double y(double v) => size.height - v / maxV * chartH;

    final slot = size.width / 7;
    final barW = math.min(slot * 0.5, 28.0);
    for (var i = 0; i < 7; i++) {
      final v = values[i];
      if (v == null) continue;
      final cx = slot * i + slot / 2;
      if (v <= 0) {
        // Rest day: a small stub on the axis so the day still reads as "logged".
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(cx - barW / 2, size.height - 4, barW, 4), const Radius.circular(2)),
          Paint()..color = stub,
        );
        continue;
      }
      final rect = Rect.fromLTRB(cx - barW / 2, y(v), cx + barW / 2, size.height);
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect, topLeft: const Radius.circular(4), topRight: const Radius.circular(4)),
        Paint()..color = i == highlight ? accent : bar,
      );
    }

    // Baseline.
    canvas.drawLine(Offset(0, size.height - 0.5), Offset(size.width, size.height - 0.5),
        Paint()
          ..color = baseline
          ..strokeWidth = 1);

    // Dashed goal line, labeled at its end.
    final gy = y(goal);
    final dash = Paint()
      ..color = guide
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, gy), Offset(math.min(x + 4, size.width), gy), dash);
    }
    label.paint(canvas, Offset(size.width - label.width, gy - label.height - 2));
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.highlight != highlight ||
      old.bar != bar ||
      old.accent != accent ||
      old.textScaler != textScaler ||
      old.labelStyle != labelStyle ||
      !_sameValues(old.values, values);

  static bool _sameValues(List<double?> a, List<double?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// ── Loading ─────────────────────────────────────────────────────────

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.xl,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Space.xs,
          children: [
            Skeleton(width: 72, height: 12),
            Skeleton(width: 160, height: 56),
            Skeleton(width: 200, height: 16),
          ],
        ),
        const Skeleton(height: _WeekChart._height, radius: Radii.m),
        Material(
          color: context.q.surface,
          shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.l)),
          child: const Column(children: [SkeletonRow(), SkeletonRow(), SkeletonRow()]),
        ),
      ],
    );
  }
}
