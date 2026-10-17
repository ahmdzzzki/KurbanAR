import SwiftUI

struct JourneyMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var currentID: String
    let saved: String
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:12) {
                    ForEach(Array(JourneyStep.all.enumerated()),id:\.element.id) { index,step in
                        Button {
                            currentID = step.id;dismiss()
                        } label: {
                            VStack(alignment:.leading,spacing:15) {
                                HStack {
                                    Text(String(format:"%02d",index+1)).font(.caption.monospaced())
                                    Spacer()
                                    if JourneyProgress(saved:saved).reviewed.contains(step.id) { Image(systemName:"checkmark").font(.caption) }
                                }.foregroundStyle(Palette.green)
                                Image(systemName:step.symbol).font(.title2).foregroundStyle(Palette.green)
                                Text(step.title).font(.subheadline.weight(.medium)).multilineTextAlignment(.leading)
                            }.frame(maxWidth:.infinity,minHeight:115,alignment:.topLeading).padding(18)
                                .background(currentID == step.id ? Palette.sage : .white,in:RoundedRectangle(cornerRadius:22))
                        }.buttonStyle(.plain).accessibilityIdentifier("jump.\(step.id)")
                    }
                }.padding(22).frame(maxWidth:700).frame(maxWidth:.infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink)
                .navigationTitle("Alur lengkap").navigationBarTitleDisplayMode(.inline)
                .toolbar { Button("Tutup") { dismiss() } }
        }.tint(Palette.green)
    }
}

struct JourneyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let step: JourneyStep
    let route: PurchaseRoute
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:22) {
                    Image(systemName:step.symbol).font(.largeTitle).foregroundStyle(Palette.green)
                    Text(step.title).font(.system(.title,design:.serif))
                    Label(step.id == "buy" ? route.buyer : step.actor,systemImage:"person.circle").font(.subheadline.weight(.medium))
                    Text(step.id == "plan" ? route.explanation : step.detail).font(.body).lineSpacing(5)
                    Text("Gambaran umum. Pengaturan dapat berbeda antarpenyelenggara.").font(.footnote).foregroundStyle(.secondary)
                    Link("Rujukan tahap ini",destination:step.source).font(.subheadline)
                }.padding(25).frame(maxWidth:650).frame(maxWidth:.infinity,alignment:.leading)
            }.background(Palette.cream).foregroundStyle(Palette.ink)
                .navigationTitle("Detail tahap").navigationBarTitleDisplayMode(.inline)
                .toolbar { Button("Tutup") { dismiss() } }
        }.tint(Palette.green).presentationDetents([.medium,.large])
    }
}

struct JourneySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let route: PurchaseRoute
    let species: AnimalSpecies
    let onOverview: () -> Void
    var body: some View {
        NavigationStack {
            VStack(alignment:.leading,spacing:28) {
                Text("Satu perjalanan.\nBanyak peran.").font(.system(.largeTitle,design:.serif))
                RoleFlow(roles:[("storefront","Pengadaan"),("person.3","Pelaksanaan"),("house","Penerima")]).frame(height:180).background(Palette.mist,in:RoundedRectangle(cornerRadius:25))
                Label("\(species.title) · \(route.title.lowercased())",systemImage:"checkmark.circle").font(.headline)
                Text("Pengurban, penjual, panitia, dan petugas bekerja dalam perannya masing-masing.").font(.subheadline).foregroundStyle(.secondary)
                PrimaryButton(title:"Lihat semua tahap",symbol:"square.grid.2x2") { onOverview() }
                Spacer()
            }.padding(26).frame(maxWidth:700).frame(maxWidth:.infinity,alignment:.leading)
                .background(Palette.cream).foregroundStyle(Palette.ink).navigationTitle("Perjalanan lengkap").navigationBarTitleDisplayMode(.inline)
                .toolbar { Button("Tutup") { dismiss() } }
        }.tint(Palette.green)
    }
}

struct AboutJourneyView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section(AppBrand.name+" · 0.5") {
                    Text("Perjalanan visual kurban untuk siapa pun, dari pengadaan hewan sampai penyaluran daging.")
                    Text("Gambaran umum, bukan panduan teknik penyembelihan. Materi masih perlu ditinjau ahli sebelum rilis.")
                }
                Section("Privasi") {
                    Text("Pilihan alur tersimpan di perangkat. Tanpa akun, iklan, atau analitik. Kamera AR tidak direkam atau dikirim oleh aplikasi.")
                }
                Section("Rujukan") {
                    Link("Panduan fikih kurban · LBM PWNU Jateng",destination:JourneyStep.all[0].source)
                    Link("Penanganan hewan dan daging · Kementan",destination:JourneyStep.all[4].source)
                    Link("Pengaturan distribusi · Kemenag",destination:JourneyStep.all[8].source)
                }
            }.navigationTitle("Tentang").navigationBarTitleDisplayMode(.inline).toolbar { Button("Tutup") { dismiss() } }
        }.tint(Palette.green)
    }
}
