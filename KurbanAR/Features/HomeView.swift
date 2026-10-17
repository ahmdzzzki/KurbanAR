import SwiftUI

struct HomeView: View {
    @Binding var tab: AppTab
    @AppStorage("completedLessons") private var saved = ""
    @State private var about = false
    private var progress: LearningProgress { LearningProgress(saved: saved) }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    HStack {
                        Label("kurbanar", systemImage: "sparkle").font(.title3.weight(.bold))
                        Spacer()
                        Button { about = true } label: { Image(systemName: "info.circle").font(.title3) }
                            .accessibilityLabel("Tentang KurbanAR")
                    }
                    Eyebrow(text: "Ruang belajar & berbagi")
                    Text("Pahami maknanya.\nRasakan dekatnya.")
                        .font(.system(size: 37, weight: .medium, design: .serif)).minimumScaleFactor(0.75)
                    Text("Jelajahi kurban lewat pengalaman kecil yang penuh makna.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    VStack(spacing: 0) {
                        HStack {
                            Label("KENALI DOMBA", systemImage: "viewfinder").font(.caption2.monospaced().weight(.medium))
                            Spacer()
                            Text("3D INTERAKTIF").font(.caption2.monospaced())
                        }.padding(20)
                        AnimalSceneView(isAR: false, resetToken: 0).frame(height: 225)
                            .accessibilityLabel("Model domba tiga dimensi bergaya ilustrasi")
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Kenalan lebih dekat").font(.title3.weight(.semibold))
                                Text("Putar. Amati. Pelajari.").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button { tab = .studio } label: {
                                Image(systemName: "arrow.up.right").font(.title3).padding(14)
                                    .background(Palette.green, in: Circle()).foregroundStyle(.white)
                            }.accessibilityLabel("Buka Studio AR")
                        }.padding(20)
                    }.background(Palette.sage, in: RoundedRectangle(cornerRadius: 28)).clipShape(RoundedRectangle(cornerRadius: 28))
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Eyebrow(text: "Perjalananmu")
                            Text("\(progress.completed.count) dari 3 bab selesai").font(.headline)
                        }
                        Spacer()
                        Text("\(Int(progress.fraction * 100))%")
                            .font(.system(.title2, design: .rounded).weight(.semibold))
                    }
                    ProgressView(value: progress.fraction).tint(Palette.green)
                    PrimaryButton(title: progress.completed.isEmpty ? "Mulai perjalanan" : "Lanjut belajar") { tab = .learn }
                    HStack(spacing: 12) {
                        Image(systemName: "heart.text.clipboard").font(.title2)
                        Text("Belajar dengan empati, berbagi dengan peduli.").font(.footnote)
                    }.foregroundStyle(Palette.green).padding(.bottom, 12)
                }.padding(24).frame(maxWidth: 650)
                    .frame(maxWidth: .infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink)
                .toolbar(.hidden, for: .navigationBar)
                .sheet(isPresented: $about) { AboutView() }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("KurbanAR · Prototipe 0.1") {
                    Text("Pengalaman edukasi pribadi tentang kepedulian, persiapan, dan berbagi. Materi awal masih perlu ditinjau ahli agama dan kesehatan hewan sebelum rilis publik.")
                    Text("Model domba bersifat ilustratif. Aplikasi ini bukan sertifikasi, panduan teknik penyembelihan, atau penilaian kelayakan hewan.")
                }
                Section("Privasi") {
                    Text("Progres belajar disimpan di perangkat. Kamera hanya dipakai saat mode AR aktif. Aplikasi tidak merekam atau mengirim gambar kamera dan tidak memiliki analitik maupun akun.")
                }
                Section("Bacaan pendamping") {
                    Link("Kemenag · Persiapan distribusi kurban", destination: URL(string: "https://dki.kemenag.go.id/berita/panitia-qurban-kankemenag-jakarta-utara-matangkan-distribusi-daging-kurban-pEvCv")!)
                    Link("Kementan · Pedoman kesejahteraan hewan", destination: URL(string: "https://repository.pertanian.go.id/server/api/core/bitstreams/36d3973f-8871-4070-80d4-8a5b763cda69/content")!)
                }
            }.navigationTitle("Tentang").toolbar { Button("Selesai") { dismiss() } }
        }.tint(Palette.green)
    }
}
