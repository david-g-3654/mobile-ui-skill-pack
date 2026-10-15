// _layout.tsx — root Stack for the templates (Expo Router: app/_layout.tsx). Verified on an
// iPhone 17 / iOS 27 simulator with Expo SDK 57 (react-native-screens 4.26).
//
// Two iOS 26+ gotchas this layout avoids:
// 1. Setting `headerStyle.backgroundColor` on a large-title header HIDES the large title. On iOS,
//    leave the header unstyled; `contentStyle` paints the canvas behind it. (Android still needs it.)
// 2. Header titles set from inside a pushed screen (<Stack.Screen options> in the component) can
//    fail to appear. Declare static options (title, headerLargeTitle) here; keep only dynamic ones
//    (headerRight, counts) in the screen.
import { Platform } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useQTheme } from '../theme';

export default function Layout() {
  const { c } = useQTheme();
  return (
    <>
      <StatusBar style="auto" />
      <Stack
        screenOptions={{
          headerShadowVisible: false,
          headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
          headerTintColor: c.ink,
          headerTitleStyle: { fontWeight: '600' },
          contentStyle: { backgroundColor: c.canvas },
          headerBackButtonDisplayMode: 'minimal',
        }}
      >
        <Stack.Screen name="index" options={{ title: 'September', headerLargeTitle: true }} />
        <Stack.Screen name="settings" options={{ title: 'Settings', headerLargeTitle: true }} />
        <Stack.Screen name="paywall" options={{ presentation: 'fullScreenModal', headerShown: false }} />
      </Stack>
    </>
  );
}
