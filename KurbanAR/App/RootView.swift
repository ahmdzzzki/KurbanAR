import SwiftUI

enum AppTab: Hashable { case home, learn, studio, day, distribute }

struct RootView: View {
    @State private var tab: AppTab = .home
    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--reset-learning-progress") {
            for key in ["completedLessons","learnerStage","dayActivityCompleted","sharingMissionCompleted"] { UserDefaults.standard.removeObject(forKey:key) }
        }
        if ProcessInfo.processInfo.arguments.contains("--camera-smoke-test") || ProcessInfo.processInfo.arguments.contains("--studio-preview") { _tab = State(initialValue: .studio) }
        #endif
    }
    var body: some View {
        TabView(selection: $tab) {
            HomeView(tab: $tab).tabItem { Label("Beranda", systemImage: "house") }.tag(AppTab.home)
            LearnView().tabItem { Label("Misi", systemImage: "star") }.tag(AppTab.learn)
            StudioView(tab: $tab).tabItem { Label("Studio AR", systemImage: "arkit") }.tag(AppTab.studio)
            DayExperienceView().tabItem { Label("Hari Kurban", systemImage:"sun.max") }.tag(AppTab.day)
            DistributionView().tabItem { Label("Berbagi", systemImage: "gift") }.tag(AppTab.distribute)
        }.tint(tab == .home ? Palette.linen : Palette.green)
            .preferredColorScheme(tab == .home || tab == .studio ? .dark : .light)
    }
}
