import SwiftUI
import ARKit
import AVFoundation

struct StudioView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var activeAR = false
    @State private var resetToken = 0
    @State private var requestingCamera = false
    @State private var status = "Putar model dengan dua jari. Cubit untuk mengubah ukuran."
    @State private var showSettings = false
    private var arSupported: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return ARWorldTrackingConfiguration.isSupported
        #endif
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Eyebrow(text: "Eksplorasi dengan rasa ingin tahu")
                    Text("Bawa rasa dekat\nke ruangmu.").font(.system(size: 36, weight: .medium, design: .serif))
                    HStack {
                        Label(activeAR ? "KAMERA AR" : "PREVIEW 3D", systemImage: activeAR ? "arkit" : "cube")
                        Spacer()
                        Text("DOMBA").tracking(2)
                    }.font(.caption.monospaced()).foregroundStyle(Palette.green)
                    AnimalSceneView(isAR: activeAR, resetToken: resetToken) { message in status = message }
                        .id(activeAR)
                        .frame(height: 350).clipShape(RoundedRectangle(cornerRadius: 28))
                        .accessibilityLabel(activeAR ? "Kamera AR. Ketuk meja atau lantai untuk menaruh domba." : "Model domba interaktif")
                    Text(status).font(.subheadline).foregroundStyle(.secondary)
                    if arSupported {
                        PrimaryButton(title: activeAR ? "Kembali ke preview" : "Hadirkan di ruangan", symbol: activeAR ? "cube" : "arkit") {
                            if activeAR { stopAR() } else { requestAR() }
                        }.disabled(requestingCamera)
                        if activeAR {
                            Button("Letakkan ulang", systemImage: "arrow.counterclockwise") { resetToken += 1 }
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        Label("Mode AR perlu iPhone atau iPad yang mendukung ARKit. Preview 3D tetap bisa kamu jelajahi.", systemImage: "info.circle")
                            .font(.footnote).paperCard()
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Model ilustratif", systemImage: "leaf").font(.headline)
                        Text("Amati bentuk dari berbagai sisi. Model ini bukan acuan ukuran, umur, kesehatan, maupun kelayakan hewan kurban.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }.paperCard()
                }.padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink)
                .navigationTitle("Studio AR").navigationBarTitleDisplayMode(.inline)
                .onDisappear { stopAR() }
                .onChange(of: scenePhase) { _, phase in if phase != .active { stopAR() } }
                .alert("Akses kamera diperlukan", isPresented: $showSettings) {
                    Button("Buka Pengaturan") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                    }
                    Button("Tetap di preview", role: .cancel) { }
                } message: { Text("Izinkan kamera untuk meletakkan domba di ruangan. Preview 3D bisa digunakan tanpa kamera.") }
        }
    }
    private func stopAR() {
        activeAR = false
        status = "Putar model dengan dua jari. Cubit untuk mengubah ukuran."
    }
    private func requestAR() {
        guard arSupported else { return }
        requestingCamera = true
        Task { @MainActor in
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            requestingCamera = false
            if granted && scenePhase == .active {
                resetToken = 0
                status = "Gerakkan kamera perlahan, lalu ketuk permukaan datar."
                activeAR = true
            } else if !granted { showSettings = true }
        }
    }
}
