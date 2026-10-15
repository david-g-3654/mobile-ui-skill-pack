// Stats archetype (mobile-ui/references/screen-stats.md).
// Job: see how far I ran this week. Focal: the weekly distance hero.
// Primary action: none — the week stepper and the bar chart are the interactions.
// Cut: the Day/Month/Year segmented control (this screen is week-scoped), extra charts, stat tiles.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

class StatsEvalApp extends StatelessWidget {
  const StatsEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stride',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _WeeklyStatsScreen(),
    );
  }
}

// ── Sample data ─────────────────────────────────────────────────────

const _weeklyGoalKm = 40.0;
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _dayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _dayLong = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

class _Run {
  const _Run(this.day, this.kind, this.km, this.seconds, this.startedAt);
  final int day; // 0 = Monday
  final String kind;
  final double km;
  final int seconds;
  final String startedAt;
}

class _Week {
  const _Week(this.monday, this.runs, {this.todayIndex});
  final DateTime monday;
  final List<_Run> runs;

  /// Set for the week in progress: days after it haven't happened yet.
  final int? todayIndex;

  bool get inProgress => todayIndex != null;
  DateTime date(int day) => monday.add(Duration(days: day));
  double kmOn(int day) => runs.where((r) => r.day == day).fold(0.0, (s, r) => s + r.km);
  double kmThrough(int day) => runs.where((r) => r.day <= day).fold(0.0, (s, r) => s + r.km);
  double get km => runs.fold(0.0, (s, r) => s + r.km);
  int get seconds => runs.fold(0, (s, r) => s + r.seconds);
}

// Oldest first. "Today" is Wednesday, Oct 14, 2026.
final _weeks = <_Week>[
  _Week(DateTime(2026, 9, 21), const []),
  _Week(DateTime(2026, 9, 28), const [
    _Run(1, 'Easy run', 6.4, 2130, '7:05 am'),
    _Run(3, 'Steady run', 8.0, 2600, '6:48 am'),
    _Run(5, '5K race', 5.0, 1368, '9:00 am'),
    _Run(6, 'Long run', 14.1, 4805, '8:20 am'),
  ]),
  _Week(DateTime(2026, 10, 5), const [
    _Run(0, 'Easy run', 7.1, 2380, '6:55 am'),
    _Run(2, 'Intervals', 9.6, 2952, '6:30 pm'),
    _Run(3, 'Recovery jog', 5.0, 1815, '7:10 am'),
    _Run(5, 'Easy run', 8.3, 2758, '8:45 am'),
    _Run(6, 'Long run', 16.2, 5560, '8:05 am'),
  ]),
  _Week(DateTime(2026, 10, 12), const [
    _Run(0, 'Easy run', 6.2, 2092, '6:51 am'),
    _Run(1, 'Recovery jog', 4.8, 1745, '7:02 am'),
    _Run(2, 'Tempo run', 10.4, 3158, '6:42 am'),
  ], todayIndex: 2),
];

// ── Formatting ──────────────────────────────────────────────────────

String _km(double v) => v.toStringAsFixed(1);
String _md(DateTime d) => '${_months[d.month - 1]} ${d.day}';

String _duration(int s) {
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  final mm = m.toString().padLeft(2, '0'), ss = sec.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$m:$ss';
}

String _pace(int seconds, double km) {
  final p = (seconds / km).round();
  return "${p ~/ 60}'${(p % 60).toString().padLeft(2, '0')}\"";
}

String _range(_Week w) {
  final a = w.monday, b = w.date(6);
  return a.month == b.month ? '${_md(a)}–${b.day}' : '${_md(a)} – ${_md(b)}';
}

// ── Screen ──────────────────────────────────────────────────────────

class _WeeklyStatsScreen extends StatefulWidget {
  const _WeeklyStatsScreen();

  @override
  State<_WeeklyStatsScreen> createState() => _WeeklyStatsScreenState();
}

class _WeeklyStatsScreenState extends State<_WeeklyStatsScreen> {
  int _index = _weeks.length - 1;
  int? _selectedDay;

  _Week get _week => _weeks[_index];
  _Week? get _previous => _index > 0 ? _weeks[_index - 1] : null;

  void _step(int by) {
    HapticFeedback.selectionClick();
    setState(() {
      _index += by;
      _selectedDay = null;
    });
  }

  void _select(int day) {
    HapticFeedback.selectionClick();
    setState(() => _selectedDay = _selectedDay == day ? null : day);
  }

  String get _weekTitle => switch (_weeks.length - 1 - _index) {
        0 => 'This week',
        1 => 'Last week',
        _ => 'Week of ${_md(_week.monday)}',
      };

  @override
  Widget build(BuildContext context) {
    final w = _week;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Running')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, Space.xxl),
            sliver: SliverList.list(
              children: [
                _WeekStepper(
                  title: _weekTitle,
                  range: _range(w),
                  onPrevious: _index > 0 ? () => _step(-1) : null,
                  onNext: _index < _weeks.length - 1 ? () => _step(1) : null,
                ),
                const SizedBox(height: Space.xl),
                _hero(context, w),
                const SizedBox(height: Space.xl),
                _WeekChart(week: w, selectedDay: _selectedDay, onSelect: _select),
                const SizedBox(height: Space.xl),
                MetricRow(items: [
                  (w.runs.isEmpty ? '—' : _duration(w.seconds), 'Time'),
                  (w.runs.isEmpty ? '—' : '${_pace(w.seconds, w.km)} /km', 'Avg pace'),
                  ('${w.runs.length}', w.runs.length == 1 ? 'Run' : 'Runs'),
                ]),
                const SizedBox(height: Space.xxl),
                GroupedSection(
                  header: 'Runs',
                  children: w.runs.isEmpty
                      ? [
                          ListRow(
                            title: 'No runs logged',
                            subtitle: 'Runs you record between ${_range(w)} show up here.',
                          ),
                        ]
                      : [
                          for (final r in w.runs.reversed)
                            ListRow(
                              title: r.kind,
                              subtitle: '${_dayShort[r.day]}, ${_md(w.date(r.day))} · ${_duration(r.seconds)} · '
                                  '${_pace(r.seconds, r.km)} /km',
                              value: '${_km(r.km)} km',
                            ),
                        ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, _Week w) {
    final day = _selectedDay;
    final Widget hero;
    if (day != null) {
      final runs = w.runs.where((r) => r.day == day).toList();
      hero = HeroMetric(
        key: ValueKey('day-$_index-$day'),
        label: '${_dayLong[day]}, ${_md(w.date(day))}',
        value: _km(w.kmOn(day)),
        suffix: ' km',
        context: runs.isEmpty
            ? 'Rest day'
            : runs.map((r) => '${r.kind} · ${_duration(r.seconds)} · ${_pace(r.seconds, r.km)} /km').join('\n'),
      );
    } else {
      final prev = _previous;
      Delta? delta;
      String? vs;
      if (prev != null && prev.runs.isNotEmpty) {
        // Mid-week, compare against the same point last week — never a partial week vs a full one.
        final before = w.inProgress ? prev.kmThrough(w.todayIndex!) : prev.km;
        final diff = w.km - before;
        vs = w.inProgress ? 'vs last ${_dayLong[w.todayIndex!]}' : 'vs the week before';
        delta = Delta('${_km(diff.abs())} km', up: diff >= 0);
      }
      hero = HeroMetric(
        key: ValueKey('week-$_index'),
        label: 'Distance',
        value: _km(w.km),
        suffix: ' km',
        delta: delta,
        context: [?vs, 'goal ${_weeklyGoalKm.toStringAsFixed(0)} km'].join(' · '),
      );
    }
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.fast,
      switchInCurve: Motion.curve,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topLeft,
        children: [...previous, ?current],
      ),
      child: hero,
    );
  }
}

// ── Week stepper ────────────────────────────────────────────────────

class _WeekStepper extends StatelessWidget {
  const _WeekStepper({required this.title, required this.range, required this.onPrevious, required this.onNext});

  final String title;
  final String range;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous week',
          onPressed: onPrevious,
          color: q.ink,
          disabledColor: q.ink3,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text('$title · $range', textAlign: TextAlign.center, style: context.t.bodyMedium),
          ),
        ),
        IconButton(
          tooltip: 'Next week',
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

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.week, required this.selectedDay, required this.onSelect});

  final _Week week;
  final int? selectedDay;
  final ValueChanged<int> onSelect;

  static const double _height = 168;
  static const double _goalPerDay = _weeklyGoalKm / 7;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final values = [for (var d = 0; d < 7; d++) week.kmOn(d)];
    final peak = values.fold(_goalPerDay, (a, b) => a > b ? a : b) * 1.15;
    final highlight = selectedDay ?? week.todayIndex;
    final goalY = _height - _goalPerDay / peak * _height;
    final summary = week.runs.isEmpty
        ? 'Kilometres per day: no runs this week.'
        : 'Kilometres per day: ${[
            for (var d = 0; d < 7; d++)
              if (!(week.inProgress && d > week.todayIndex!)) '${_dayLong[d]} ${_km(values[d])}',
          ].join(', ')}. Goal pace ${_km(_goalPerDay)} a day.';

    return Semantics(
      container: true,
      label: summary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.xs,
        children: [
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: Space.xs,
              children: [
                CustomPaint(size: const Size(Space.md, 1), painter: _DashPainter(q.ink2)),
                Flexible(child: Text('Goal pace, ${_km(_goalPerDay)} km a day', style: context.t.bodySmall)),
              ],
            ),
          ),
          SizedBox(
            height: _height,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var d = 0; d < 7; d++)
                      Expanded(
                        child: _Bar(
                          label: '${_dayLong[d]}, ${_km(values[d])} km',
                          height: values[d] / peak * _height,
                          future: week.inProgress && d > week.todayIndex!,
                          color: d == highlight ? q.accent : q.ink.withValues(alpha: 0.85),
                          selected: d == selectedDay,
                          onTap: week.inProgress && d > week.todayIndex! ? null : () => onSelect(d),
                        ),
                      ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: goalY,
                  child: IgnorePointer(
                    child: CustomPaint(size: const Size.fromHeight(1), painter: _DashPainter(q.ink2)),
                  ),
                ),
                if (week.runs.isEmpty)
                  Center(
                    child: ExcludeSemantics(
                      child: Text('No runs this week', style: context.t.bodyMedium),
                    ),
                  ),
              ],
            ),
          ),
          ExcludeSemantics(
            child: Row(
              children: [
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _dayShort[d],
                        style: context.t.bodySmall?.copyWith(
                          color: d == highlight ? q.ink : q.ink2,
                          fontWeight: d == highlight ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
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

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.height,
    required this.future,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double height;
  final bool future;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final empty = future || height <= 0;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: future ? null : label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            widthFactor: 0.56,
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.medium,
              curve: Motion.curve,
              height: empty ? Space.xxs : height,
              decoration: BoxDecoration(
                color: empty ? q.surface2 : color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Space.xxs)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += Space.xs) {
      canvas.drawLine(Offset(x, 0), Offset(x + Space.xxs, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
