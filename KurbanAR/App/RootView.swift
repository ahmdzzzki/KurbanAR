import SwiftUI

enum AppTab: Hashable { case home, learn, studio, distribute }

struct RootView: View {
    @State private var tab: AppTab = .home
    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--camera-smoke-test") || ProcessInfo.processInfo.arguments.contains("--studio-preview") { _tab = State(initialValue: .studio) }
        #endif
    }
    var body: some View {
        TabView(selection: $tab) {
            HomeView(tab: $tab).tabItem { Label("Beranda", systemImage: "house") }.tag(AppTab.home)
            LearnView().tabItem { Label("Belajar", systemImage: "book.closed") }.tag(AppTab.learn)
            StudioView(tab: $tab).tabItem { Label("Studio AR", systemImage: "arkit") }.tag(AppTab.studio)
            DistributionView().tabItem { Label("Distribusi", systemImage: "shippingbox") }.tag(AppTab.distribute)
        }.tint(tab == .home ? Palette.linen : Palette.green)
            .preferredColorScheme(tab == .home || tab == .studio ? .dark : .light)
    }
}
