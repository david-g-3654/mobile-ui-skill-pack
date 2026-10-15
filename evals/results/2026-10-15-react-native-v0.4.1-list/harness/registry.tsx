// Registry of every eval screen, shared by the dev host (app/index.tsx) and the release host (app/[screen].tsx).
import React from 'react';
import BaseHome from './base/home';
import BaseSettings from './base/settings';
import BasePaywall from './base/paywall';
import BaseOnboarding from './base/onboarding';
import BaseDetail from './base/detail';
import BaseList from './base/list';
import BaseStats from './base/stats';
import BaseAuth from './base/auth';
import PackHome from './pack/home';
import PackSettings from './pack/settings';
import PackPaywall from './pack/paywall';
import PackOnboarding from './pack/onboarding';
import PackDetail from './pack/detail';
import PackList from './pack/list';
import PackStats from './pack/stats';
import PackAuth from './pack/auth';
import HeroStats from './hero/stats';
import IntlProbe from './probe/intl';
import Pack041List from './pack041/list';
import Pack04Home from './pack04/home';
import Pack04Settings from './pack04/settings';
import Pack04Paywall from './pack04/paywall';
import Pack04Onboarding from './pack04/onboarding';
import Pack04Detail from './pack04/detail';
import Pack04List from './pack04/list';
import Pack04Stats from './pack04/stats';
import Pack04Auth from './pack04/auth';

export const SCREENS: Record<string, React.ComponentType> = {
  'base-home': BaseHome,
  'base-settings': BaseSettings,
  'base-paywall': BasePaywall,
  'base-onboarding': BaseOnboarding,
  'base-detail': BaseDetail,
  'base-list': BaseList,
  'base-stats': BaseStats,
  'base-auth': BaseAuth,
  'pack-home': PackHome,
  'pack-settings': PackSettings,
  'pack-paywall': PackPaywall,
  'pack-onboarding': PackOnboarding,
  'pack-detail': PackDetail,
  'pack-list': PackList,
  'pack-stats': PackStats,
  'pack-auth': PackAuth,
  'hero-stats': HeroStats,
  'probe-intl': IntlProbe,
  'pack041-list': Pack041List,
  'pack04-home': Pack04Home,
  'pack04-settings': Pack04Settings,
  'pack04-paywall': Pack04Paywall,
  'pack04-onboarding': Pack04Onboarding,
  'pack04-detail': Pack04Detail,
  'pack04-list': Pack04List,
  'pack04-stats': Pack04Stats,
  'pack04-auth': Pack04Auth,
};

