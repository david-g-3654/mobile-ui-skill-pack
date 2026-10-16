import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_eval/pack04/theme.dart';
import 'package:fl_eval/pack04/components.dart';

class PaywallEvalApp extends StatelessWidget {
  const PaywallEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _PaywallScreen(),
    );
  }
}

class _PaywallScreen extends StatefulWidget {
  const _PaywallScreen();

  @override
  State<_PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<_PaywallScreen> {
  bool _yearly = true;
  bool _closed = false;

  void _showMessage(String title, String message) {
    showAdaptiveDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  List<Widget> _footer(BuildContext context) => [
    Text(
      _yearly
          ? '\$39.99/year, billed yearly. Renews automatically.\nNo free trial. Cancel anytime in store settings.'
          : '\$5.99/month, billed monthly. Renews automatically.\nNo free trial. Cancel anytime in store settings.',
      style: context.qText.bodySmall,
      textAlign: TextAlign.center,
    ),
    Wrap(
      alignment: WrapAlignment.center,
      spacing: QSpace.xs,
      children: [
        TextButton(
          onPressed: () => _showMessage(
            'Subscription terms',
            'Both plans include all Daybook Plus features. Your selected '
                'plan renews automatically at the displayed price unless '
                'canceled in your app store settings before renewal. '
                'This is a UI preview; no purchase will be made.',
          ),
          child: const Text('Terms'),
        ),
        TextButton(
          onPressed: () => _showMessage(
            'Your privacy',
            'This preview uses sample content and does not collect or upload '
                'journal entries. A production app must provide its full '
                'privacy policy before accepting subscriptions.',
          ),
          child: const Text('Privacy'),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_closed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daybook')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(QSpace.margin),
            children: [
              Text(
                'A little space to reflect.',
                style: context.qText.titleLarge,
              ),
              const SizedBox(height: QSpace.sm),
              Text(
                'Your free journal is still yours. Come back to Plus whenever you’re ready.',
                style: context.qText.bodyMedium,
              ),
              const SizedBox(height: QSpace.xl),
              TextButton(
                onPressed: () => setState(() => _closed = false),
                child: const Text('Explore Daybook Plus'),
              ),
            ],
          ),
        ),
      );
    }

    final monthly = QPlanCard(
      name: 'Monthly',
      price: '\$5.99',
      period: '/month',
      detail: 'Billed monthly',
      selected: !_yearly,
      onTap: () => setState(() => _yearly = false),
    );
    final yearly = QPlanCard(
      name: 'Yearly',
      price: '\$39.99',
      period: '/year',
      detail: 'Just \$3.33/month',
      badge: 'Save 44%',
      selected: _yearly,
      onTap: () => setState(() => _yearly = true),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close paywall',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => setState(() => _closed = true),
        ),
        actions: [
          TextButton(
            onPressed: () => _showMessage(
              'Restore purchases',
              'No purchases were restored. This preview is not connected '
                  'to an app store. In the live app, purchases are restored '
                  'using your store account.',
            ),
            child: const Text('Restore'),
          ),
          const SizedBox(width: QSpace.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    QSpace.margin,
                    QSpace.xs,
                    QSpace.margin,
                    QSpace.xxl,
                  ),
                  sliver: SliverList.list(
                    children: [
                      Row(
                        spacing: QSpace.sm,
                        children: [
                          ExcludeSemantics(
                            child: Icon(
                              Icons.auto_stories_rounded,
                              color: context.q.ink,
                              size: QSpace.xxl,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Daybook Plus',
                              style: context.qText.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: QSpace.xl),
                      Semantics(
                        header: true,
                        child: QDisplayScale(
                          child: Text(
                            'Make room\nfor yourself.',
                            style: context.qText.headlineLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: QSpace.sm),
                      Text(
                        'Go beyond the day-to-day. Find the patterns,\nkeep the moments, and get to know you.',
                        style: context.qText.bodyMedium,
                      ),
                      const SizedBox(height: QSpace.xl),
                      const Column(
                        spacing: QSpace.sm,
                        children: [
                          _Benefit('Find your words with guided prompts'),
                          _Benefit('See your mood patterns over time'),
                          _Benefit('Keep every memory with unlimited photos'),
                        ],
                      ),
                      const SizedBox(height: QSpace.xxl),
                      if (qIsLargeText(context))
                        Column(
                          spacing: QSpace.sm,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [monthly, yearly],
                        )
                      else
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: QSpace.sm,
                            children: [
                              Expanded(child: monthly),
                              Expanded(child: yearly),
                            ],
                          ),
                        ),
                      QLargeTextFooter(children: _footer(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: QBottomActionBar(
        footer: _footer(context),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: QPrimaryButton(
                label: _yearly ? 'Subscribe yearly' : 'Subscribe monthly',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showMessage(
                    'Subscription preview',
                    _yearly
                        ? 'You selected Daybook Plus for \$39.99/year. No charge '
                              'has been made. Store checkout is not connected in this preview.'
                        : 'You selected Daybook Plus for \$5.99/month. No charge '
                              'has been made. Store checkout is not connected in this preview.',
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: QSpace.sm,
      children: [
        ExcludeSemantics(
          child: Icon(
            Icons.check_rounded,
            color: context.q.ink,
            size: QSpace.lg,
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: context.qText.bodyMedium?.copyWith(color: context.q.ink),
          ),
        ),
      ],
    );
  }
}
