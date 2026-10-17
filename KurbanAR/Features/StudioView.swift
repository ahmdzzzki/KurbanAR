import SwiftUI
import ARKit
import AVFoundation

struct StudioView: View {
    @Binding var tab: AppTab
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("selectedAnimal") private var selectedAnimal = AnimalSpecies.cattle.rawValue
    @State private var activeAR = false
    @State private var sceneVisible = false
    @State private var resetToken = 0
    @State private var requestingCamera = false
    @State private var spinning = true
    @State private var observation: AnimalObservation?
    @State private var feedback = SceneFeedback(phase: .loading, message: "Menyiapkan studio…")
    @State private var cameraHelp = false
    @State private var cameraPrimer = false
    @State private var showSettings = false
    private var species: AnimalSpecies { AnimalSpecies(rawValue: selectedAnimal) ?? .cattle }
    private var arSupported: Bool {
        #if targetEnvironment(simulator)
        false
        #else
        ARWorldTrackingConfiguration.isSupported
        #endif
    }
    var body: some View {
        ZStack {
            if sceneVisible { AnimalSceneView(species: species, isAR: activeAR, resetToken: resetToken,
                            autoRotate: spinning && !reduceMotion, observation: observation) { feedback = $0 }
                .id(activeAR).ignoresSafeArea()
                .accessibilityIdentifier("studio.scene") }
            VStack {
                LinearGradient(colors: [.black.opacity(0.5),.clear], startPoint: .top, endPoint: .bottom).frame(height: 270)
                Spacer()
                LinearGradient(colors: [.clear,Palette.midnight.opacity(activeAR ? 0.7 : 1)],startPoint: .top,endPoint: .bottom).frame(height: 350)
            }.ignoresSafeArea().allowsHitTesting(false)
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    circleButton("Kembali ke beranda", symbol: "arrow.left") { tab = .home }
                    Spacer()
                    Label(activeAR ? "KAMERA AR" : "STUDIO 3D", systemImage: activeAR ? "camera.fill" : "viewfinder")
                        .font(.caption.monospaced().weight(.semibold)).tracking(1.5)
                    Spacer()
                    circleButton("Bantuan kamera", symbol: "questionmark") { cameraHelp = true }
                }
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(species.title).font(.system(size: 48, weight: .regular, design: .serif))
                            .accessibilityIdentifier("studio.animalName")
                        Text(species.detail).font(.caption).foregroundStyle(.white.opacity(0.65))
                    }
                    Spacer()
                    VStack(spacing: 12) {
                        if !activeAR {
                            circleButton(spinning ? "Jeda putaran" : "Putar otomatis",symbol: spinning ? "pause.fill" : "play.fill") { spinning.toggle() }
                        }
                        circleButton(activeAR ? "Mulai ulang AR" : "Reset sudut pandang",symbol: "arrow.counterclockwise") { resetToken += 1 }
                    }
                }
                Spacer(minLength: 100)
                if let observation {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(observation.title,systemImage: "scope").font(.headline)
                            Spacer()
                            Button { self.observation = nil } label: { Image(systemName: "xmark.circle.fill") }.accessibilityLabel("Tutup pengamatan")
                        }
                        Text(observation.text(for: species)).font(.footnote).lineSpacing(3).foregroundStyle(.white.opacity(0.8))
                    }.padding(18).background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius: 22))
                }
                VStack(spacing: 15) {
                    AnimalPicker(selection: $selectedAnimal)
                    HStack(spacing: 8) {
                        ForEach(AnimalObservation.allCases) { point in
                            Button {
                                observation = observation == point ? nil : point
                                spinning = false
                                UISelectionFeedbackGenerator().selectionChanged()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle").font(.caption)
                                    Text(point.title).font(.caption.weight(.medium))
                                }.padding(.vertical,6).frame(maxWidth:.infinity)
                            }.liquidButton(prominent:observation == point).accessibilityIdentifier("observation.\(point.rawValue)")
                        }
                    }
                    HStack(alignment: .top, spacing: 10) {
                        Circle().fill(statusColor).frame(width: 7,height: 7).padding(.top,5)
                        Text(feedback.message).font(.caption).foregroundStyle(.white.opacity(0.75))
                            .frame(maxWidth: .infinity,alignment:.leading).accessibilityIdentifier("studio.status")
                    }.frame(minHeight: 32)
                    Button {
                        if activeAR { stopAR() } else if arSupported { cameraPrimer = true } else { cameraHelp = true }
                    } label: {
                        HStack {
                            Image(systemName: activeAR ? "cube.transparent" : "arkit")
                            Text(requestingCamera ? "Meminta akses kamera…" : (activeAR ? "Kembali ke studio 3D" : "Hadirkan di duniamu"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }.font(.subheadline.weight(.semibold)).padding(.vertical,10).padding(.horizontal,6)
                            .foregroundStyle(.white)
                    }.liquidButton().disabled(requestingCamera).accessibilityIdentifier("studio.camera")
                    if activeAR && (feedback.phase == .failed || feedback.phase == .interrupted) {
                        Button("Mulai ulang AR",systemImage:"arrow.clockwise") { resetToken += 1 }.font(.caption.weight(.semibold))
                    }
                }
            }.padding(.horizontal,24).padding(.top,12).padding(.bottom,14).frame(maxWidth:700)
        }.overlay {
            if feedback.phase == .loading || feedback.phase == .starting {
                ProgressView().tint(Palette.gold).scaleEffect(1.3).allowsHitTesting(false)
            }
        }.background(Palette.midnight).foregroundStyle(.white)
            .toolbar(.hidden,for:.tabBar)
            .onAppear { sceneVisible = true }
            .onDisappear { sceneVisible = false; stopAR() }
            .task {
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--camera-smoke-test") { requestAR() }
                #endif
            }
            // A permission prompt temporarily makes the app inactive. Only backgrounding stops AR.
            .onChange(of: scenePhase) { _, phase in if phase == .background { stopAR() } }
            .onChange(of: selectedAnimal) { _, _ in observation = nil }
            .sheet(isPresented:$cameraHelp) { CameraHelpView(isSimulator: !arSupported) }
            .confirmationDialog("Hadirkan hewan di ruangan",isPresented:$cameraPrimer,titleVisibility:.visible) {
                Button("Mulai kamera") { requestAR() }
                Button("Tetap di studio 3D",role:.cancel) { }
            } message: {
                Text("Kamera membuat hewan 3D tampak hadir di ruanganmu. Gambar tidak direkam. Pilih tempat lapang dan tetap perhatikan sekeliling.")
            }
            .alert("Izinkan akses kamera",isPresented:$showSettings) {
                Button("Buka Pengaturan") {
                    if let url = URL(string:UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                }
                Button("Nanti",role:.cancel) { }
            } message: { Text("Di Pengaturan, aktifkan Kamera untuk aplikasi ini. Gambar hanya dipakai untuk AR dan tidak direkam.") }
    }
    private var statusColor: Color {
        switch feedback.phase { case .failed,.interrupted: .orange; case .ready,.placed: Palette.gold; default: .white.opacity(0.5) }
    }
    private func circleButton(_ title: String,symbol: String,action:@escaping () -> Void) -> some View {
        Button(action:action) { Image(systemName:symbol).font(.system(size:15,weight:.semibold)).frame(width:28,height:28) }
            .liquidButton().accessibilityLabel(title)
    }
    private func stopAR() {
        activeAR = false
        requestingCamera = false
    }
    private func requestAR() {
        guard arSupported else { cameraHelp = true;return }
        switch AVCaptureDevice.authorizationStatus(for:.video) {
        case .authorized: activateCamera()
        case .notDetermined:
            requestingCamera = true
            Task { @MainActor in
                let granted = await AVCaptureDevice.requestAccess(for:.video)
                requestingCamera = false
                if granted { activateCamera() } else { showSettings = true }
            }
        case .denied,.restricted: showSettings = true
        @unknown default: showSettings = true
        }
    }
    private func activateCamera() {
        guard tab == .studio, CameraActivationPolicy.shouldActivate(granted:true,supported:arSupported,isBackground:scenePhase == .background) else { return }
        observation = nil;resetToken = 0
        feedback = SceneFeedback(phase:.starting,message:"Menghubungkan kamera…")
        activeAR = true
    }
}

struct AnimalPicker: View {
    @Binding var selection: String
    var body: some View {
        HStack(spacing:10) {
            ForEach(AnimalSpecies.allCases) { species in
                let selected = selection == species.rawValue
                Button {
                    selection = species.rawValue
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    HStack(spacing:12) {
                        Text(species.index).font(.caption.monospaced()).foregroundStyle(selected ? Palette.gold : .white.opacity(0.4))
                        Text(species.title).font(.subheadline.weight(.semibold))
                        Spacer()
                        Image(systemName:selected ? "checkmark.circle.fill" : "circle").font(.subheadline)
                            .foregroundStyle(selected ? Palette.gold : .white.opacity(0.25))
                    }.padding(.vertical,9).padding(.horizontal,5)
                }.liquidButton(prominent:selected).accessibilityIdentifier("animal.\(species.rawValue)")
                    .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }.foregroundStyle(.white)
    }
}

struct CameraHelpView: View {
    @Environment(\.dismiss) private var dismiss
    let isSimulator: Bool
    var body: some View {
        NavigationStack {
            List {
                if isSimulator {
                    Section("Kamera AR perlu perangkat fisik") {
                        Text("Simulator Xcode tidak menyediakan kamera AR. Jalankan aplikasi di iPhone/iPad yang mendukung ARKit. Studio 3D tetap interaktif di sini.")
                    }
                }
                Section("Mulai pengalaman AR") {
                    Label("Izinkan kamera saat diminta.",systemImage:"camera")
                    Label("Arahkan ke lantai atau meja yang terang dan memiliki pola.",systemImage:"sun.max")
                    Label("Gerakkan perlahan sampai status permukaan ditemukan, lalu ketuk area tersebut.",systemImage:"hand.tap")
                    Label("Geser untuk memindahkan, cubit untuk ukuran, dan putar dengan dua jari.",systemImage:"hand.draw")
                }
                Section("Jika kamera kosong") {
                    Text("Tekan Mulai ulang AR. Periksa Pengaturan aplikasi → Kamera. Jika kamera sedang digunakan aplikasi lain, tutup aplikasi tersebut lalu coba kembali.")
                }
                Section("Tentang model") {
                    Text("Sapi dan domba adalah ilustrasi 3D dengan proporsi lebih natural. Ukuran AR dapat diubah dan bukan ukuran hewan sebenarnya. Model tidak menilai umur, kesehatan, atau kelayakan kurban.")
                }
            }.navigationTitle("Panduan studio").navigationBarTitleDisplayMode(.inline)
                .toolbar { Button("Selesai") { dismiss() } }.tint(Palette.green)
        }.presentationDetents([.medium,.large])
    }
}
