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
};

