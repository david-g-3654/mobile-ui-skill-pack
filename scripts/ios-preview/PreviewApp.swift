// PreviewApp.swift — tiny host app for rendering the SwiftUI templates on a simulator.
// Pick a screen with the launch argument `-screen home|homeLoading|settings|paywall`.
import SwiftUI

@main
struct MobileUIPreviewApp: App {
    private let screen = UserDefaults.standard.string(forKey: "screen") ?? "home"
    var body: some Scene {
        WindowGroup {
            switch screen {
            case "settings": SettingsScreen()
            case "paywall": PaywallScreen()
            case "homeLoading": HomeScreen(isLoading: true)
            default: HomeScreen()
            }
        }
    }
}
