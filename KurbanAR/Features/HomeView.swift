import SwiftUI

struct HomeView: View {
    @Binding var tab: AppTab
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("selectedAnimal") private var selectedAnimal = AnimalSpecies.cattle.rawValue
    @AppStorage("completedLessons") private var saved = ""
    @State private var about = false
    @State private var sceneVisible = false
    private var species: AnimalSpecies { AnimalSpecies(rawValue: selectedAnimal) ?? .cattle }
    private var progress: LearningProgress { LearningProgress(saved: saved) }
    var body: some View {
        ZStack {
            if sceneVisible { AnimalSceneView(species:species,autoRotate:!reduceMotion).ignoresSafeArea() }
            VStack {
                LinearGradient(colors:[Palette.midnight.opacity(0.95),.clear],startPoint:.top,endPoint:.bottom).frame(height:320)
                Spacer()
                LinearGradient(colors:[.clear,Palette.midnight],startPoint:.top,endPoint:.bottom).frame(height:380)
            }.ignoresSafeArea().allowsHitTesting(false)
            VStack(alignment:.leading,spacing:18) {
                HStack {
                    Label("kurbanar",systemImage:"sparkle").font(.title3.weight(.bold))
                    Spacer()
                    Button { about = true } label: {
                        Image(systemName:"info").font(.subheadline.weight(.semibold)).frame(width:44,height:44)
                            .background(.white.opacity(0.10),in:Circle())
                    }.accessibilityLabel("Tentang KurbanAR")
                }
                HStack(spacing:8) {
                    Circle().fill(Palette.gold).frame(width:6,height:6)
                    Text("SEBUAH PERJALANAN SPASIAL").font(.system(size:10,weight:.medium,design:.monospaced)).tracking(2)
                }.foregroundStyle(Palette.gold)
                Text("Lebih dekat.\nLebih bermakna.")
                    .font(.system(size:43,weight:.regular,design:.serif)).minimumScaleFactor(0.7)
                Text("Kenali. Peduli. Berbagi.").font(.subheadline).foregroundStyle(.white.opacity(0.6))
                Spacer(minLength:20)
                HStack(alignment:.bottom) {
                    VStack(alignment:.leading,spacing:5) {
                        Text("KOLEKSI / \(species.index)").font(.caption2.monospaced()).tracking(2).foregroundStyle(Palette.gold)
                        Text(species.title).font(.system(size:30,weight:.medium,design:.serif))
                    }
                    Spacer()
                    Label("LIVE 3D",systemImage:"viewfinder").font(.caption2.monospaced())
                        .padding(10).background(.white.opacity(0.08),in:Capsule())
                }
                AnimalPicker(selection:$selectedAnimal)
                Button { tab = .studio } label: {
                    HStack {
                        Image(systemName:"arkit")
                        Text("Masuk studio interaktif")
                        Spacer()
                        Image(systemName:"arrow.up.right")
                    }.font(.subheadline.weight(.semibold)).padding(19).foregroundStyle(Palette.midnight)
                        .background(Palette.linen,in:RoundedRectangle(cornerRadius:20))
                }.buttonStyle(.plain).accessibilityLabel("Buka Studio AR")
                HStack(spacing:15) {
                    Button { tab = .learn } label: {
                        VStack(alignment:.leading,spacing:5) {
                            Label("Perjalanan belajar",systemImage:"book.closed").font(.caption.weight(.medium))
                            Text("\(progress.completed.count) dari 3 bab selesai").font(.caption2).foregroundStyle(.white.opacity(0.5))
                        }.frame(maxWidth:.infinity,alignment:.leading)
                    }
                    Rectangle().fill(.white.opacity(0.15)).frame(width:1,height:30)
                    Button { tab = .distribute } label: {
                        VStack(alignment:.leading,spacing:5) {
                            Label("Latihan berbagi",systemImage:"shippingbox").font(.caption.weight(.medium))
                            Text("Rencanakan distribusi").font(.caption2).foregroundStyle(.white.opacity(0.5))
                        }.frame(maxWidth:.infinity,alignment:.leading)
                    }
                }.buttonStyle(.plain).padding(.top,5)
            }.padding(.horizontal,24).padding(.top,8).padding(.bottom,12).frame(maxWidth:700)
        }.background(Palette.midnight).foregroundStyle(.white)
            .onAppear { sceneVisible = true }
            .onDisappear { sceneVisible = false }
            .sheet(isPresented:$about) { AboutView() }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("KurbanAR · Prototipe 0.2") {
                    Text("Pengalaman edukasi pribadi tentang kepedulian, persiapan, dan berbagi. Materi awal masih perlu ditinjau ahli agama dan kesehatan hewan sebelum rilis publik.")
                    Text("Model sapi dan domba bersifat ilustratif. Aplikasi ini bukan sertifikasi, panduan teknik penyembelihan, atau penilaian kelayakan hewan.")
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
