# React Native release-build harness

The eval's React Native screenshots were first taken in Expo Go, which draws a developer-tools button over every screen. The gallery and the React Native contact sheet now come from a **Release** build of the same eval app, which has no dev tools and no Metro.

```bash
npx expo install expo-build-properties                  # SDK 57: then set ios.enableSceneSupport (app.json)
npx expo prebuild --platform ios                        # in the eval app (needs CocoaPods)
npx expo run:ios --configuration Release --device "iPhone 17" --no-bundler
xcrun simctl launch booted dev.mobileui.evalrn -screen pack-stats   # any key from registry.tsx
```

- **Screen selection:** `index.tsx` reads the `-screen` launch argument through React Native's `Settings` module (NSUserDefaults), with every screen listed in `registry.tsx`. One build covers all of them. Deep links didn't survive a cold start here, so the harness doesn't use them.
- **iOS 27 scene life cycle:** with the iOS 27 SDK, an app that hasn't adopted the UIScene life cycle is stopped at launch (`UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption`). On Expo SDK 57 (57.0.23 or later), turn on Expo's official opt-in, `expo-build-properties` → `ios.enableSceneSupport: true` (see `app.json` here and [expo/expo#46664](https://github.com/expo/expo/issues/46664)). SDK 58 does this by default.
- **Deep links:** in this harness, a deep link that cold-starts the app opened the default route, though the same link worked with the app running. A clean `create-expo-app` project with the same Expo 57.0.28, expo-router 57.0.26 and `enableSceneSupport` handles cold-start links correctly, to both static and dynamic routes, so the cause is something in this harness, not Expo. Launch arguments sidestep it.
- **Status-bar breadcrumb:** iOS shows "◀ OtherApp" when an app is launched while another app is in front. Terminate other apps before each capture.
