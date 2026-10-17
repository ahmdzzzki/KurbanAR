import SwiftUI

struct HomeView: View {
    @Binding var tab: AppTab
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("journeyCurrentStep") private var currentID = JourneyStep.all[0].id
    @AppStorage("purchaseRoute") private var purchaseRaw = PurchaseRoute.direct.rawValue
    @AppStorage("deliveryRoute") private var deliveryRaw = DeliveryRoute.deliver.rawValue
    @AppStorage("selectedAnimal") private var selectedAnimal = AnimalSpecies.cattle.rawValue
    @AppStorage("journeyReviewed") private var saved = ""
    @StateObject private var speaker = StorySpeaker()
    @State private var map = false
    @State private var detail = false
    @State private var about = false
    @State private var summary = false
    private var index: Int { JourneyStep.index(for:currentID) }
    private var step: JourneyStep { JourneyStep.all[index] }
    private var route: PurchaseRoute { PurchaseRoute(rawValue:purchaseRaw) ?? .direct }
    private var species: AnimalSpecies { AnimalSpecies(rawValue:selectedAnimal) ?? .cattle }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:18) {
                    GlassControls { HStack(spacing:12) {
                        Text(AppBrand.name).font(.system(.title2,design:.serif).weight(.semibold))
                        Spacer()
                        Button { map = true } label: {
                            Image(systemName:"square.grid.2x2").frame(width:28,height:28)
                        }.liquidButton().accessibilityLabel("Lihat alur").accessibilityIdentifier("journey.map")
                        Button { about = true } label: {
                            Image(systemName:"info").font(.subheadline.weight(.medium)).frame(width:28,height:28)
                        }.liquidButton().accessibilityLabel("Tentang aplikasi")
                    } }
                    Text("DARI NIAT KE MANFAAT").font(.system(size:10,weight:.medium,design:.monospaced)).tracking(1.8).foregroundStyle(Palette.green)
                    ProgressView(value:Double(index+1),total:Double(JourneyStep.all.count)).tint(Palette.green)
                    HStack {
                        Text(String(format:"%02d",index+1)).font(.system(.largeTitle,design:.rounded).weight(.light))
                        Text("/ \(JourneyStep.all.count)").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text(step.actor).font(.caption).multilineTextAlignment(.trailing).foregroundStyle(Palette.green)
                    }
                    JourneyVisual(stepID:step.id,route:route,delivery:DeliveryRoute(rawValue:deliveryRaw) ?? .deliver,species:species)
                        .frame(height:230).frame(maxWidth:.infinity)
                        .background(step.id == "choose" ? Palette.midnight : Palette.mist,in:RoundedRectangle(cornerRadius:28))
                        .clipShape(RoundedRectangle(cornerRadius:28))
                        .accessibilityElement(children:.contain)
                        .accessibilityLabel("Ilustrasi tahap: \(step.title)")
                        .accessibilityIdentifier("journey.visual")
                        .simultaneousGesture(DragGesture(minimumDistance:40).onEnded { value in
                            guard step.id != "choose", abs(value.translation.width) > abs(value.translation.height)*1.5 else { return }
                            if value.translation.width < -60 && index < JourneyStep.all.count-1 { advance() }
                            else if value.translation.width > 60 && index > 0 { move(to:index-1) }
                        })
                    VStack(alignment:.leading,spacing:10) {
                        Text(step.title).font(.system(size:30,weight:.medium,design:.serif)).accessibilityIdentifier("journey.title")
                        Text(contextCaption).font(.subheadline).foregroundStyle(.secondary).lineSpacing(3).accessibilityIdentifier("journey.caption")
                    }
                    controls
                    HStack(spacing:16) {
                        Button { detail = true } label: { Label("Lihat detail",systemImage:"plus.circle").padding(.horizontal,4).frame(minHeight:28) }
                            .liquidButton().accessibilityIdentifier("journey.detail")
                        Spacer()
                        Button {
                            if speaker.speaking { speaker.stop() } else { speaker.read(step.title+". "+contextCaption) }
                        } label: { Image(systemName:speaker.speaking ? "stop.fill" : "speaker.wave.2").frame(width:28,height:28) }
                            .liquidButton().accessibilityLabel(speaker.speaking ? "Hentikan narasi" : "Dengarkan tahap ini")
                    }.font(.subheadline).padding(.vertical,3)

                }.padding(.horizontal,24).padding(.top,8).padding(.bottom,20).frame(maxWidth:700).frame(maxWidth:.infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink).toolbar(.hidden,for:.navigationBar)
                .safeAreaInset(edge:.bottom) { navigationButtons.padding(.horizontal,24).padding(.top,8).background { LinearGradient(colors:[Palette.cream.opacity(0),Palette.cream,Palette.cream],startPoint:.top,endPoint:.bottom).ignoresSafeArea(edges:.bottom).allowsHitTesting(false) } }
                .onDisappear { speaker.stop() }
                .onChange(of:currentID) { _,_ in speaker.stop() }
                .onChange(of:scenePhase) { _,phase in if phase != .active { speaker.stop() } }
                .sheet(isPresented:$map) { JourneyMapView(currentID:$currentID,saved:saved) }
                .sheet(isPresented:$detail) { JourneyDetailView(step:step,route:route) }
                .sheet(isPresented:$about) { AboutJourneyView() }
                .sheet(isPresented:$summary) { JourneySummaryView(route:route,species:species) { summary = false;map = true } }
        }
    }
    private var navigationButtons: some View {
        GlassControls { HStack(spacing:12) {
            if index > 0 {
                Button { move(to:index-1) } label: { Image(systemName:"arrow.left").frame(width:32,height:44) }
                    .liquidButton().accessibilityLabel("Tahap sebelumnya")
            }
            PrimaryButton(title:index == JourneyStep.all.count-1 ? "Lihat perjalanan lengkap" : "Lanjut",symbol:"arrow.right") {
                advance()
            }.accessibilityIdentifier("journey.next")
        } }.padding(.bottom,10)
    }
    private var contextCaption: String {
        switch step.id {
        case "plan": return "Pengurban adalah orang yang berkurban. Pengadaan bisa diurus sendiri atau dititipkan."
        case "buy": return route == .direct ? "Pengurban membeli langsung dari penjual." : "Panitia atau lembaga membeli atas mandat pengurban."
        case "distribute": return deliveryRaw == "deliver" ? "Tim mengantar paket kepada penerima dan mencatat penyalurannya." : "Penerima mengambil paket sesuai pengaturan panitia."
        default: return step.caption
        }
    }
    @ViewBuilder private var controls: some View {
        if step.id == "plan" || step.id == "buy" { RoutePicker(route:$purchaseRaw) }
        if step.id == "choose" {
            HStack(spacing:10) {
                ForEach(AnimalSpecies.allCases) { animal in
                    Button { selectedAnimal = animal.rawValue;UISelectionFeedbackGenerator().selectionChanged() } label: {
                        HStack { Text(animal.title);Spacer();Image(systemName:selectedAnimal == animal.rawValue ? "checkmark.circle.fill" : "circle") }
                            .font(.subheadline.weight(.semibold)).padding(.vertical,9).padding(.horizontal,5)
                            .foregroundStyle(selectedAnimal == animal.rawValue ? .white : Palette.ink)
                    }.liquidButton(prominent:selectedAnimal == animal.rawValue).accessibilityIdentifier("journey.animal.\(animal.rawValue)")
                }
            }
        }
        if step.id == "pack" {
            Button { tab = .distribute } label: { Label("Coba hitung paket",systemImage:"scalemass") }.font(.subheadline)
        }
        if step.id == "distribute" {
            Picker("Cara penyaluran",selection:$deliveryRaw) {
                ForEach(DeliveryRoute.allCases) { item in Text(item.title).tag(item.rawValue) }
            }.pickerStyle(.segmented).accessibilityIdentifier("journey.delivery")
        }
    }
    private func advance() {
        var progress = JourneyProgress(saved:saved)
        _ = progress.review(step.id);saved = progress.saved
        if index < JourneyStep.all.count-1 { move(to:index+1) } else { summary = true }
    }
    private func move(to next: Int) {
        speaker.stop()
        withAnimation(reduceMotion ? nil : .easeInOut(duration:0.22)) {
            currentID = JourneyStep.all[min(max(next,0),JourneyStep.all.count-1)].id
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

struct JourneyVisual: View {
    let stepID: String
    let route: PurchaseRoute
    let delivery: DeliveryRoute
    let species: AnimalSpecies
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        switch stepID {
        case "choose": AnimalSceneView(species:species,autoRotate:!reduceMotion)
        case "plan","buy":
            RoleFlow(roles:route == .direct ? [("person","Pengurban"),("storefront","Penjual")] : [("person","Pengurban"),("person.2","Panitia"),("storefront","Penjual")])
        case "receive": RoleFlow(roles:[("truck.box","Pengantar"),("doc.text","Catatan"),("person.2","Panitia")])
        case "care": RoleFlow(roles:[("drop","Perawatan"),("heart.text.clipboard","Pemeriksaan")])
        case "prepare": RoleFlow(roles:[("person.3","Tim"),("square.dashed","Area"),("checklist","Kesiapan")])
        case "slaughter":
            VStack(spacing:18) {
                Image(systemName:"person.fill.checkmark").font(.system(size:70,weight:.ultraLight)).foregroundStyle(Palette.green)
                Text("Tugas petugas terlatih").font(.subheadline.weight(.medium))
                Text("Ilustrasi simbolis").font(.caption).foregroundStyle(.secondary)
            }
        case "inspect": RoleFlow(roles:[("person.badge.shield.checkmark","Pemeriksa"),("checkmark.shield","Kelayakan")])
        case "pack": PackingIllustration()
        default:
            RoleFlow(roles:delivery == .deliver ? [("shippingbox","Paket"),("truck.box","Diantar"),("house","Penerima")] : [("shippingbox","Paket"),("person.2","Diambil"),("checkmark.circle","Dicatat")])
        }
    }
}
