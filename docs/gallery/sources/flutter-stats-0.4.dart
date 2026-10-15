// Weekly running stats — mobile-ui "Stats" archetype, default Quiet skin.
// Job: see how far you've run this week. Focal: the distance hero. Primary action: none —
// the Week/Month control, the period stepper and tapping a bar are the interactions.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack04/components.dart';
import 'package:fl_eval/pack04/theme.dart';

class StatsHeroApp extends StatelessWidget {
  const StatsHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Running stats',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _RunningStatsScreen(),
    );
  }
}

// ── Sample data ─────────────────────────────────────────────────────

class _Run {
  const _Run(this.date, this.name, this.miles, this.seconds);
  final DateTime date;
  final String name;
  final double miles;
  final int seconds;
}

/// Sample data is anchored to a fixed "today" (Wednesday) so the screen renders the same everywhere.
final DateTime _today = DateTime(2026, 10, 14);
final DateTime _dataStart = DateTime(2026, 9, 1);
const double _weeklyGoal = 25;

final List<_Run> _runs = [
  _Run(DateTime(2026, 9, 1), 'Easy run', 4.1, 36 * 60 + 40),
  _Run(DateTime(2026, 9, 3), 'Tempo run', 5.0, 40 * 60 + 15),
  _Run(DateTime(2026, 9, 6), 'Long run', 9.2, 3600 + 24 * 60 + 30),
  _Run(DateTime(2026, 9, 8), 'Easy run', 3.6, 32 * 60 + 5),
  _Run(DateTime(2026, 9, 10), 'Hill repeats', 6.0, 52 * 60 + 48),
  _Run(DateTime(2026, 9, 12), 'Easy run', 4.4, 38 * 60 + 50),
  _Run(DateTime(2026, 9, 13), 'Long run', 10.1, 3600 + 33 * 60 + 10),
  _Run(DateTime(2026, 9, 15), 'Easy run', 4.2, 37 * 60 + 20),
  _Run(DateTime(2026, 9, 17), 'Track · 6×800 m', 5.5, 45 * 60 + 30),
  _Run(DateTime(2026, 9, 20), 'Long run', 11.3, 3600 + 43 * 60 + 55),
  // Sep 21–27: no runs (head cold).
  _Run(DateTime(2026, 9, 29), 'Easy run', 3.1, 29 * 60 + 40),
  _Run(DateTime(2026, 10, 1), 'Easy run', 4.0, 36 * 60 + 12),
  _Run(DateTime(2026, 10, 4), 'Long run', 7.6, 3600 + 9 * 60 + 45),
  _Run(DateTime(2026, 10, 6), 'Easy run', 4.8, 42 * 60 + 30),
  _Run(DateTime(2026, 10, 7), 'Recovery jog', 3.2, 30 * 60 + 10),
  _Run(DateTime(2026, 10, 8), 'Tempo run', 6.2, 50 * 60 + 5),
  _Run(DateTime(2026, 10, 11), 'Long run', 10.4, 3600 + 33 * 60 + 40),
  _Run(DateTime(2026, 10, 12), 'Easy run', 5.2, 45 * 60 + 36),
  _Run(DateTime(2026, 10, 14), 'Tempo run', 6.8, 54 * 60 + 12),
];

// ── Formatting ──────────────────────────────────────────────────────

const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September',
  'October', 'November', 'December'];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _mon(DateTime d) => _months[d.month - 1].substring(0, 3);
String _dayLong(DateTime d) => '${_weekdays[d.weekday - 1]}, ${_mon(d)} ${d.day}';
String _mi(double m) => m.toStringAsFixed(1);

String _duration(int s) {
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(sec)}' : '$m:${two(sec)}';
}

String _pace(int seconds, double miles) {
  if (miles <= 0) return '—';
  final p = (seconds / miles).round();
  return '${p ~/ 60}\'${(p % 60).toString().padLeft(2, '0')}"';
}

DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

// ── Period model ────────────────────────────────────────────────────

enum _Period { week, month }

class _Range {
  _Range(this.period, this.offset) {
    if (period == _Period.week) {
      final thisWeek = _addDays(_today, -(_today.weekday - 1));
      start = _addDays(thisWeek, offset * 7);
      days = 7;
    } else {
      start = DateTime(_today.year, _today.month + offset, 1);
      days = DateTime(start.year, start.month + 1, 0).day;
    }
  }

  final _Period period;
  final int offset;
  late final DateTime start;
  late final int days;

  bool get isCurrent => offset == 0;
  DateTime get end => _addDays(start, days);

  /// Days that have happened so far (all of them for a past period).
  int get elapsed => isCurrent ? _today.difference(start).inDays + 1 : days;

  List<_Run> runsWithin(int dayCount) {
    final stop = _addDays(start, dayCount);
    return _runs.where((r) => !r.date.isBefore(start) && r.date.isBefore(stop)).toList();
  }

  List<_Run> get runs => runsWithin(elapsed);

  _Range get previous => _Range(period, offset - 1);

  bool get canGoBack => previous.end.isAfter(_dataStart);

  String get title {
    if (period == _Period.month) {
      return isCurrent ? 'This month · ${_months[start.month - 1]}' : '${_months[start.month - 1]} ${start.year}';
    }
    final last = _addDays(start, 6);
    final span = start.month == last.month
        ? '${_mon(start)} ${start.day}–${last.day}'
        : '${_mon(start)} ${start.day} – ${_mon(last)} ${last.day}';
    if (offset == 0) return 'This week · $span';
    if (offset == -1) return 'Last week · $span';
    return span;
  }
}

// ── Screen ──────────────────────────────────────────────────────────

class _RunningStatsScreen extends StatefulWidget {
  const _RunningStatsScreen();

  @override
  State<_RunningStatsScreen> createState() => _RunningStatsScreenState();
}

class _RunningStatsScreenState extends State<_RunningStatsScreen> {
  _Period _period = _Period.week;
  int _offset = 0;
  int? _selectedDay;
  bool _showAllRuns = false;

  _Range get _range => _Range(_period, _offset);

  void _setPeriod(_Period p) {
    HapticFeedback.selectionClick();
    setState(() {
      _period = p;
      _offset = 0;
      _selectedDay = null;
      _showAllRuns = false;
    });
  }

  void _step(int delta) {
    setState(() {
      _offset += delta;
      _selectedDay = null;
      _showAllRuns = false;
    });
  }

  void _toggleDay(int i) {
    HapticFeedback.selectionClick();
    setState(() => _selectedDay = _selectedDay == i ? null : i);
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    final runs = range.runs;
    final unit = _period == _Period.week ? 'week' : 'month';

    // Daily totals; null for days that haven't happened yet.
    final daily = <double?>[
      for (var i = 0; i < range.days; i++)
        i < range.elapsed
            ? runs.where((r) => _sameDay(r.date, _addDays(range.start, i))).fold<double>(0, (s, r) => s + r.miles)
            : null,
    ];
    final labels = <String>[
      for (var i = 0; i < range.days; i++)
        _period == _Period.week
            ? _weekdays[i].substring(0, 1)
            : ((i % 7 == 0) ? '${i + 1}' : ''),
    ];
    final highlight = _selectedDay ?? (range.isCurrent ? range.elapsed - 1 : null);

    final totalMiles = runs.fold<double>(0, (s, r) => s + r.miles);
    final totalSeconds = runs.fold<int>(0, (s, r) => s + r.seconds);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Running')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xs, QSpace.margin, QSpace.xxl),
            sliver: SliverList.list(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<_Period>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: _Period.week, label: Text('Week')),
                      ButtonSegment(value: _Period.month, label: Text('Month')),
                    ],
                    selected: {_period},
                    onSelectionChanged: (s) => _setPeriod(s.first),
                  ),
                ),
                const SizedBox(height: QSpace.xs),
                _PeriodStepper(
                  title: range.title,
                  unit: unit,
                  onPrevious: range.canGoBack ? () => _step(-1) : null,
                  onNext: range.isCurrent ? null : () => _step(1),
                ),
                const SizedBox(height: QSpace.xl),
                _hero(context, range, daily, totalMiles),
                const SizedBox(height: QSpace.xl),
                _BarChart(
                  values: daily,
                  labels: labels,
                  dayNames: [for (var i = 0; i < range.days; i++) _dayLong(_addDays(range.start, i))],
                  highlight: highlight,
                  emptyMessage: 'No runs this $unit',
                  onTapBar: _toggleDay,
                ),
                const SizedBox(height: QSpace.xxl),
                QMetricRow(items: [
                  (_duration(totalSeconds), 'Time'),
                  (_pace(totalSeconds, totalMiles), 'Avg pace per mile'),
                  ('${runs.length}', runs.length == 1 ? 'Run' : 'Runs'),
                ]),
                const SizedBox(height: QSpace.xxl),
                _runList(context, range, runs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, _Range range, List<double?> daily, double totalMiles) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    late final Widget hero;

    final sel = _selectedDay;
    if (sel != null) {
      final day = _addDays(range.start, sel);
      final dayRuns = range.runs.where((r) => _sameDay(r.date, day)).toList();
      hero = QHeroMetric(
        key: ValueKey('day-$sel-${range.start}'),
        label: _dayLong(day),
        value: _mi(daily[sel] ?? 0),
        suffix: ' mi',
        context: dayRuns.isEmpty
            ? 'Rest day'
            : dayRuns.map((r) => '${r.name} · ${_duration(r.seconds)}').join(', '),
      );
    } else {
      // Compare like with like: mid-period, against the same number of days of the previous period.
      final prev = range.previous;
      QDelta? delta;
      if (!prev.start.isBefore(_dataStart)) {
        final prevMiles = prev.runsWithin(range.elapsed.clamp(0, prev.days)).fold<double>(0, (s, r) => s + r.miles);
        final diff = totalMiles - prevMiles;
        if (diff.abs() >= 0.05) {
          final against = range.isCurrent
              ? (_period == _Period.week ? 'this time last week' : 'this point last month')
              : (_period == _Period.week ? 'the week before' : _months[prev.start.month - 1]);
          delta = QDelta('${_mi(diff.abs())} mi vs. $against', up: diff > 0);
        }
      }
      String? goal;
      if (_period == _Period.week) {
        goal = totalMiles >= _weeklyGoal
            ? 'Weekly goal of ${_weeklyGoal.round()} mi met'
            : '${(totalMiles / _weeklyGoal * 100).round()}% of ${_weeklyGoal.round()} mi goal';
      }
      hero = QHeroMetric(
        key: ValueKey('total-${range.start}-$_period'),
        label: 'Distance',
        value: _mi(totalMiles),
        suffix: ' mi',
        delta: delta,
        context: goal,
      );
    }

    return AnimatedSwitcher(
      duration: reduceMotion ? Duration.zero : QMotion.medium,
      switchInCurve: QMotion.curve,
      switchOutCurve: QMotion.curve,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topLeft,
        children: [...previous, ?current],
      ),
      child: hero,
    );
  }

  Widget _runList(BuildContext context, _Range range, List<_Run> runs) {
    final newestFirst = runs.reversed.toList();
    if (newestFirst.isEmpty) {
      return QGroupedSection(
        header: 'Runs',
        children: [
          QListRow(
            title: 'Nothing logged',
            subtitle: range.isCurrent
                ? 'Runs you record this ${_period.name} show up here.'
                : 'No runs were recorded in this ${_period.name}.',
          ),
        ],
      );
    }
    const visibleCap = 7;
    final shown = _showAllRuns ? newestFirst : newestFirst.take(visibleCap).toList();
    final hidden = newestFirst.length - shown.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: QSpace.xs,
      children: [
        QGroupedSection(
          header: 'Runs',
          children: [
            for (final r in shown)
              MergeSemantics(
                child: QListRow(
                  title: r.name,
                  subtitle: '${_dayLong(r.date)} · ${_duration(r.seconds)} · ${_pace(r.seconds, r.miles)} /mi',
                  value: '${_mi(r.miles)} mi',
                ),
              ),
          ],
        ),
        if (hidden > 0)
          QTertiaryButton(
            label: 'Show all ${newestFirst.length} runs',
            onPressed: () => setState(() => _showAllRuns = true),
          ),
      ],
    );
  }
}

// ── Period stepper ──────────────────────────────────────────────────

class _PeriodStepper extends StatelessWidget {
  const _PeriodStepper({required this.title, required this.unit, this.onPrevious, this.onNext});

  final String title;
  final String unit;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous $unit',
          onPressed: onPrevious,
          color: q.ink,
          disabledColor: q.ink3,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(title, textAlign: TextAlign.center, style: context.qText.bodyMedium),
          ),
        ),
        IconButton(
          tooltip: 'Next $unit',
          onPressed: onNext,
          color: q.ink,
          disabledColor: q.ink3,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

// ── Bar chart ───────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.values,
    required this.labels,
    required this.dayNames,
    required this.highlight,
    required this.emptyMessage,
    required this.onTapBar,
  });

  final List<double?> values;
  final List<String> labels;
  final List<String> dayNames;
  final int? highlight;
  final String emptyMessage;
  final ValueChanged<int> onTapBar;

  static const double _plotHeight = 168;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final footnote = context.qText.bodySmall;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final peak = values.fold<double>(0, (m, v) => v != null && v > m ? v : m);
    final isEmpty = peak == 0;
    // Round the guide up to an even number of miles.
    final scaleMax = isEmpty ? 2.0 : ((peak / 2).ceil() * 2).toDouble();

    final summary = isEmpty
        ? emptyMessage
        : 'Miles per day. ${[
            for (var i = 0; i < values.length; i++)
              if (values[i] != null) '${dayNames[i]} ${_mi(values[i]!)}',
          ].join(', ')}';

    return Semantics(
      container: true,
      label: summary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _plotHeight,
            child: Column(
              children: [
                ExcludeSemantics(
                  child: Row(
                    spacing: QSpace.xs,
                    children: [
                      Expanded(child: Divider(color: q.hairline)),
                      Text('${scaleMax.round()} mi', style: footnote),
                    ],
                  ),
                ),
                Expanded(
                  child: isEmpty
                      ? Center(child: Text(emptyMessage, style: context.qText.bodyMedium))
                      : LayoutBuilder(
                          builder: (context, box) => Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (var i = 0; i < values.length; i++)
                                Expanded(child: _bar(context, i, box.maxHeight, scaleMax, reduceMotion)),
                            ],
                          ),
                        ),
                ),
                Divider(color: q.hairline),
              ],
            ),
          ),
          const SizedBox(height: QSpace.xs),
          ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    // Month labels ("15", "29") may be wider than a day slot at large text: let them
                    // paint past the slot instead of wrapping digit by digit.
                    child: Text(
                      labels[i],
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                      style: footnote?.copyWith(color: i == highlight ? q.ink : q.ink2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, int i, double maxHeight, double scaleMax, bool reduceMotion) {
    final q = context.q;
    final v = values[i];
    if (v == null) return const SizedBox.shrink(); // day hasn't happened yet

    final isHighlight = i == highlight;
    final restDay = v == 0;
    final height = restDay ? 2.0 : (v / scaleMax * maxHeight).clamp(4.0, maxHeight);
    final color = isHighlight ? q.accent : (restDay ? q.surface2 : q.ink.withValues(alpha: 0.85));

    return Semantics(
      button: true,
      selected: isHighlight,
      label: '${dayNames[i]}, ${restDay ? 'rest day' : '${_mi(v)} miles'}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTapBar(i),
        child: SizedBox(
          height: maxHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            // 60% bar, 40% gap.
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: AnimatedContainer(
                duration: reduceMotion ? Duration.zero : QMotion.medium,
                curve: QMotion.curve,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
