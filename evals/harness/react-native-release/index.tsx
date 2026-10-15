// Eval host. Dev (Expo Go): renders the screen named in current.ts. Release build: launch with
// `xcrun simctl launch booted dev.mobileui.evalrn -screen <name>`; the argument lands in
// NSUserDefaults, which React Native's Settings module reads (iOS).
import React from 'react';
import { Platform, Settings } from 'react-native';
import { SCREEN } from '../current';
import { SCREENS } from '../screens/registry';

export default function Index() {
  const fromLaunch = Platform.OS === 'ios' ? (Settings.get('screen') as string | undefined) : undefined;
  const Screen = SCREENS[fromLaunch ?? SCREEN];
  return Screen ? <Screen /> : null;
}
