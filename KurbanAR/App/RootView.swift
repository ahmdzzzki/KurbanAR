import SwiftUI

enum AppTab: Hashable { case home, learn, studio, distribute }

struct RootView: View {
    @State private var tab: AppTab = .home
    var body: some View {
        TabView(selection: $tab) {
            HomeView(tab: $tab).tabItem { Label("Beranda", systemImage: "house") }.tag(AppTab.home)
            LearnView().tabItem { Label("Belajar", systemImage: "book.closed") }.tag(AppTab.learn)
            StudioView().tabItem { Label("Studio AR", systemImage: "arkit") }.tag(AppTab.studio)
            DistributionView().tabItem { Label("Distribusi", systemImage: "shippingbox") }.tag(AppTab.distribute)
        }.tint(Palette.green)
    }
}
