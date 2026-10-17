import SwiftUI

enum AppTab: Hashable { case home, studio, distribute }

struct RootView: View {
    @State private var tab: AppTab = .home
    init() {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--reset-journey") {
            for key in ["journeyCurrentStep","purchaseRoute","deliveryRoute","journeyReviewed","selectedAnimal"] { UserDefaults.standard.removeObject(forKey:key) }
        }
        if args.contains("--camera-smoke-test") || args.contains("--studio-preview") { _tab = State(initialValue:.studio) }
        #endif
    }
    var body: some View {
        TabView(selection:$tab) {
            HomeView(tab:$tab).tabItem { Label("Alur",systemImage:"point.topleft.down.to.point.bottomright.curvepath") }.tag(AppTab.home)
            StudioView(tab:$tab).tabItem { Label("Hewan",systemImage:"cube") }.tag(AppTab.studio)
            DistributionView().tabItem { Label("Hitung",systemImage:"scalemass") }.tag(AppTab.distribute)
        }.tint(Palette.green).preferredColorScheme(tab == .studio ? .dark : .light)
    }
}
