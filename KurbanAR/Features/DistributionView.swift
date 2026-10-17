import SwiftUI

struct DistributionView: View {
    @AppStorage("learnerStage") private var stageRaw = "sd"
    @AppStorage("sharingMissionCompleted") private var earned = false
    @State private var game = SharingGame(stage:.sd)
    @State private var checked = false
    @State private var initialized = false
    @State private var calculator = false
    private var stage: LearnerStage { LearnerStage(rawValue:stageRaw) ?? .sd }
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment:.leading,spacing:22) {
                    KidHeading(kicker:"Tantangan berbagi",title:"Satu untukmu,\nsatu untukmu juga!",detail:"Bantu membagi paket mainan sama banyak. Ketuk keluarga untuk memberi satu paket.")
                    StagePicker()
                    HStack {
                        Label("\(game.remaining) paket tersisa",systemImage:"shippingbox.fill").font(.headline)
                        Spacer()
                        Text("\(game.received.count) keluarga").font(.subheadline)
                    }.accessibilityIdentifier("sharing.stock")
                    LazyVGrid(columns:[GridItem(.adaptive(minimum:38))],spacing:10) {
                        ForEach(0..<game.total,id:\.self) { index in
                            Image(systemName:"shippingbox.fill").font(.title2).frame(height:39)
                                .foregroundStyle(index < game.remaining ? Palette.green : Palette.green.opacity(0.15))
                        }
                    }.padding(18).background(Palette.sunshine.opacity(0.5),in:RoundedRectangle(cornerRadius:24))
                    LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:13) {
                        ForEach(game.received.indices,id:\.self) { index in
                            VStack(spacing:12) {
                                Button {
                                    _ = game.deliver(to:index);checked = false
                                    UISelectionFeedbackGenerator().selectionChanged()
                                } label: {
                                    VStack(spacing:12) {
                                        Image(systemName:"person.2.fill").font(.system(size:30))
                                        Text("Keluarga \(index+1)").font(.system(.headline,design:.rounded))
                                        Text("\(game.received[index]) paket").font(.title2.bold()).contentTransition(.numericText())
                                    }.frame(maxWidth:.infinity).padding(.vertical,18)
                                }.buttonStyle(.plain).accessibilityIdentifier("family.\(index)")
                                Button("Ambil satu kembali",systemImage:"minus.circle") { _ = game.takeBack(from:index);checked = false }
                                    .font(.caption).disabled(game.received[index] == 0)
                                    .padding(.bottom,14).accessibilityIdentifier("family.undo.\(index)")
                            }.background(Palette.missionColors[index+1],in:RoundedRectangle(cornerRadius:24))
                        }
                    }
                    PrimaryButton(title:"Sudah sama banyak?",symbol:"checkmark") {
                        checked = true
                        if game.isComplete { earned = true }
                        DispatchQueue.main.async { proxy.scrollTo("sharing.feedback",anchor:.bottom) }
                    }.accessibilityIdentifier("sharing.check")
                    if checked {
                        VStack(alignment:.leading,spacing:12) {
                            Label(game.isComplete ? "Hore, semua dapat sama banyak!" : "Yuk, periksa lagi.",systemImage:game.isComplete ? "seal.fill" : "lightbulb.fill").font(.headline)
                            Text(game.isComplete ? "\(game.total) paket ÷ \(game.received.count) keluarga = \(game.total/game.received.count) paket per keluarga. Lencana Agen Berbagi untukmu!" : "Habiskan paket mainan dan buat jumlah setiap keluarga sama. Kamu bisa mengambil kembali paket yang sudah diberikan.").font(.subheadline).lineSpacing(3)
                        }.padding(22).background(game.isComplete ? Palette.sunshine : Palette.sky,in:RoundedRectangle(cornerRadius:24))
                            .accessibilityIdentifier("sharing.feedback").id("sharing.feedback")
                    }
                    Button("Main lagi",systemImage:"arrow.clockwise") { game.reset();checked = false }.font(.subheadline.bold()).padding(.vertical,10)
                    if earned { Label("Lencana: Agen Berbagi",systemImage:"seal.fill").font(.subheadline.bold()).foregroundStyle(Palette.green) }
                    Text("Ini permainan berhitung. Penerima dan pembagian kurban sebenarnya diatur oleh panitia sesuai ketentuan yang berlaku.")
                        .font(.footnote).foregroundStyle(.secondary)
                    Button { calculator = true } label: {
                        HStack { Label("Coba timbangan & gram",systemImage:"scalemass.fill");Spacer();Image(systemName:"arrow.up.right") }
                            .font(.headline).paperCard()
                    }.buttonStyle(.plain).accessibilityIdentifier("sharing.calculator")
                }.padding(22).frame(maxWidth:700).frame(maxWidth:.infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink)
                .navigationTitle("Belajar berbagi").navigationBarTitleDisplayMode(.inline)
                .onAppear { if !initialized { game = SharingGame(stage:stage);initialized = true } }
                .onChange(of:stageRaw) { _,_ in game = SharingGame(stage:stage);checked = false }
                .sheet(isPresented:$calculator) {
                    DistributionCalculator().overlay(alignment:.topTrailing) {
                        Button { calculator = false } label: { Image(systemName:"xmark.circle.fill").font(.title2).padding(18) }
                            .accessibilityLabel("Tutup timbangan")
                    }
                }
            }
        }
    }
}

struct DistributionCalculator: View {
    @State private var kilograms = 25
    @State private var packages = 20
    private var plan: DistributionPlan? {
        try? DistributionPlan(totalGrams: kilograms * 1000, packageCount: packages)
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Eyebrow(text: "Latihan berbagi")
                    Text("Setiap paket,\nsebuah kepedulian.").font(.system(size: 36, weight: .medium, design: .serif))
                    Text("Coba rencanakan pembagian daging siap kemas. Ubah angkanya dan lihat hasilnya.")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 24) {
                        Label("Rencana distribusi", systemImage: "slider.horizontal.3").font(.headline)
                        Stepper(value: $kilograms, in: 1...500) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Berat siap kemas").font(.subheadline)
                                Text("\(kilograms) kg").font(.title2.weight(.semibold))
                            }
                        }
                        Divider()
                        Stepper(value: $packages, in: 1...500) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Jumlah paket").font(.subheadline)
                                Text("\(packages) paket").font(.title2.weight(.semibold))
                            }
                        }
                    }.paperCard()
                    if let plan {
                        VStack(alignment: .leading, spacing: 22) {
                            Image(systemName: "shippingbox").font(.largeTitle)
                            Text("\(plan.gramsPerPackage)")
                                .accessibilityIdentifier("distribution.gramsPerPackage")
                                .font(.system(size: 68, weight: .medium, design: .rounded))
                                .contentTransition(.numericText())
                            Text("gram per paket").font(.title3)
                            Divider().overlay(.white.opacity(0.3))
                            HStack {
                                Label("\(plan.packageCount) paket", systemImage: "checkmark.circle")
                                Spacer()
                                Text("Sisa \(plan.remainingGrams) g")
                            }.font(.subheadline)
                        }.padding(26).frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white).background(Palette.green, in: RoundedRectangle(cornerRadius: 28))
                            .animation(.easeInOut, value: plan)
                        Text("\(plan.packageCount) × \(plan.gramsPerPackage) g + \(plan.remainingGrams) g sisa = \(plan.totalGrams) g")
                            .font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                    Label("Angka ini latihan pembagian berat, bukan ketentuan fikih atau perkiraan hasil daging hewan hidup.", systemImage: "info.circle")
                        .font(.footnote).foregroundStyle(.secondary)
                }.padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink)
                .navigationTitle("Simulasi distribusi").navigationBarTitleDisplayMode(.inline)
        }
    }
}
