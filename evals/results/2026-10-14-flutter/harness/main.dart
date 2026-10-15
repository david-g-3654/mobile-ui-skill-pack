// Eval host: shows the app named by --dart-define=EVAL_SCREEN=<arm>-<id> (one build per screen).
import 'package:flutter/widgets.dart';
import 'package:fl_eval/eval/base/home.dart' as base_home;
import 'package:fl_eval/eval/base/settings.dart' as base_settings;
import 'package:fl_eval/eval/base/paywall.dart' as base_paywall;
import 'package:fl_eval/eval/base/onboarding.dart' as base_onboarding;
import 'package:fl_eval/eval/base/detail.dart' as base_detail;
import 'package:fl_eval/eval/base/list.dart' as base_list;
import 'package:fl_eval/eval/base/stats.dart' as base_stats;
import 'package:fl_eval/eval/base/auth.dart' as base_auth;
import 'package:fl_eval/eval/pack/home.dart' as pack_home;
import 'package:fl_eval/eval/pack/settings.dart' as pack_settings;
import 'package:fl_eval/eval/pack/paywall.dart' as pack_paywall;
import 'package:fl_eval/eval/pack/onboarding.dart' as pack_onboarding;
import 'package:fl_eval/eval/pack/detail.dart' as pack_detail;
import 'package:fl_eval/eval/pack/list.dart' as pack_list;
import 'package:fl_eval/eval/pack/stats.dart' as pack_stats;
import 'package:fl_eval/eval/pack/auth.dart' as pack_auth;

final apps = <String, Widget Function()>{
  'base-home': () => const base_home.HomeEvalApp(),
  'base-settings': () => const base_settings.SettingsEvalApp(),
  'base-paywall': () => const base_paywall.PaywallEvalApp(),
  'base-onboarding': () => const base_onboarding.OnboardingEvalApp(),
  'base-detail': () => const base_detail.DetailEvalApp(),
  'base-list': () => const base_list.ListEvalApp(),
  'base-stats': () => const base_stats.StatsEvalApp(),
  'base-auth': () => const base_auth.AuthEvalApp(),
  'pack-home': () => const pack_home.HomeEvalApp(),
  'pack-settings': () => const pack_settings.SettingsEvalApp(),
  'pack-paywall': () => const pack_paywall.PaywallEvalApp(),
  'pack-onboarding': () => const pack_onboarding.OnboardingEvalApp(),
  'pack-detail': () => const pack_detail.DetailEvalApp(),
  'pack-list': () => const pack_list.ListEvalApp(),
  'pack-stats': () => const pack_stats.StatsEvalApp(),
  'pack-auth': () => const pack_auth.AuthEvalApp(),
};

void main() {
  const key = String.fromEnvironment('EVAL_SCREEN');
  final app = apps[key];
  if (app == null) throw StateError('EVAL_SCREEN=$key is not a known screen');
  runApp(app());
}
