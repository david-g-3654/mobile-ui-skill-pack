import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_eval/pack04/theme.dart';
import 'package:fl_eval/pack04/components.dart';

class OnboardingEvalApp extends StatelessWidget {
  const OnboardingEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _WelcomeScreen(),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  void _begin(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _FirstNoteSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: QBottomActionBar(
        footer: const [_Reassurance()],
        children: [
          QPrimaryButton(
            label: 'Create a note',
            onPressed: () => _begin(context),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    QSpace.margin,
                    QSpace.lg,
                    QSpace.margin,
                    QSpace.xxl,
                  ),
                  sliver: SliverList.list(
                    children: [
                      Row(
                        spacing: QSpace.xs,
                        children: [
                          ExcludeSemantics(
                            child: SizedBox(
                              width: QSpace.xl,
                              height: QSpace.xl,
                              child: _Waveform(color: context.q.ink),
                            ),
                          ),
                          Text('Murmur', style: context.qText.titleMedium),
                        ],
                      ),
                      const SizedBox(height: QSpace.xxl),
                      Semantics(
                        header: true,
                        child: QDisplayScale(
                          child: Text(
                            'Think aloud.\nKeep the\ngood parts.',
                            style: context.qText.displayLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: QSpace.sm),
                      Text(
                        'Turn a passing thought into a clear note, with AI.',
                        style: context.qText.bodyMedium,
                      ),
                      const SizedBox(height: QSpace.xxl),
                      const _NotePreview(),
                      const QLargeTextFooter(children: [_Reassurance()]),
                    ],
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

class _NotePreview extends StatelessWidget {
  const _NotePreview();

  @override
  Widget build(BuildContext context) {
    return QObjectCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: QSpace.sm,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: QSpace.md,
            runSpacing: QSpace.xxs,
            children: [
              Text('A thought, captured', style: context.qText.titleMedium),
              Text('Sample · 38 sec', style: context.qText.bodySmall),
            ],
          ),
          ExcludeSemantics(
            child: SizedBox(
              width: double.infinity,
              height: QSpace.xxl,
              child: _Waveform(color: context.q.accent),
            ),
          ),
          Text(
            '“A Sunday book swap at the café. Bring one, take one.”',
            style: context.qText.bodyMedium,
          ),
          Divider(height: QSpace.sm, color: context.q.hairline),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: QSpace.sm,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.auto_awesome_outlined,
                  size: QSpace.lg,
                  color: context.q.ink2,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: QSpace.xxs,
                  children: [
                    Text(
                      'The Sunday book swap',
                      style: context.qText.titleMedium,
                    ),
                    Text(
                      'Summarized. Titled. Easy to find.',
                      style: context.qText.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.color});

  final Color color;

  static const _levels = [
    .18,
    .32,
    .55,
    .28,
    .72,
    .94,
    .62,
    .36,
    .52,
    .8,
    .46,
    .24,
    .42,
    .7,
    1.0,
    .66,
    .4,
    .22,
    .54,
    .86,
    .6,
    .34,
    .48,
    .76,
    .5,
    .26,
    .44,
    .64,
    .38,
    .16,
    .3,
    .52,
    .74,
    .46,
    .24,
    .4,
    .6,
    .36,
    .22,
    .12,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth < QSpace.xxxl ? 5 : _levels.length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (index) {
            return Container(
              width: QSpace.xxs,
              height:
                  constraints.maxHeight * _levels[index + (count == 5 ? 3 : 0)],
              decoration: ShapeDecoration(
                color: color,
                shape: const StadiumBorder(),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Reassurance extends StatelessWidget {
  const _Reassurance();

  @override
  Widget build(BuildContext context) {
    return Text(
      'A little less typing. A little more thinking.',
      textAlign: TextAlign.center,
      style: context.qText.bodySmall,
    );
  }
}

class _FirstNoteSheet extends StatelessWidget {
  const _FirstNoteSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(QSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: QSpace.xl,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Start with a thought',
                style: context.qText.titleLarge,
              ),
            ),
            Text(
              'An idea, a reminder, a ramble. There’s no need to get it perfect.',
              style: context.qText.bodyLarge,
            ),
            Text(
              'Murmur needs microphone access to capture your voice. '
              'Recording is not connected in this preview.',
              style: context.qText.bodyMedium,
            ),
            QPrimaryButton(
              label: 'Back to welcome',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
