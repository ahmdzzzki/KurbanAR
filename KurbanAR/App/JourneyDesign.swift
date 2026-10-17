import SwiftUI
import AVFoundation

enum AppBrand {
    static let name = "Kurbanin"
}

extension Palette {
    static let sand = Color(red:0.94,green:0.91,blue:0.83)
    static let mist = Color(red:0.85,green:0.91,blue:0.89)
}

struct RoutePicker: View {
    @Binding var route: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        GlassControls { HStack(spacing:12) {
            ForEach(PurchaseRoute.allCases) { item in
                Button {
                    withAnimation(reduceMotion ? nil : .smooth(duration:0.25)) { route = item.rawValue }
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    HStack {
                        Image(systemName:item == .direct ? "person" : "person.2")
                        Text(item.title).fontWeight(.semibold)
                    }.font(.subheadline).frame(maxWidth:.infinity).padding(.vertical,8)
                        .foregroundStyle(route == item.rawValue ? .white : Palette.ink)
                }.liquidButton(prominent:route == item.rawValue).accessibilityIdentifier("purchase.\(item.rawValue)")
                    .accessibilityAddTraits(route == item.rawValue ? .isSelected : [])
            }
        } }
    }
}

struct RoleToken: View {
    let symbol: String
    let title: String
    var emphasis = false
    var body: some View {
        VStack(spacing:13) {
            Image(systemName:symbol).font(.system(size:36,weight:.light)).frame(width:76,height:82)
                .background(emphasis ? Palette.green : .white.opacity(0.8),in:RoundedRectangle(cornerRadius:25))
                .foregroundStyle(emphasis ? .white : Palette.green)
            Text(title).font(.caption.weight(.medium)).multilineTextAlignment(.center).fixedSize(horizontal:false,vertical:true)
        }.frame(maxWidth:.infinity)
    }
}

struct RoleFlow: View {
    let roles: [(String,String)]
    @State private var selectedRole: String?
    var body: some View {
        HStack(alignment:.center,spacing:3) {
            ForEach(roles.indices,id:\.self) { i in
                Button {
                    selectedRole = roles[i].1
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    RoleToken(symbol:roles[i].0,title:roles[i].1,emphasis:i == 0)
                }.buttonStyle(.plain)
                    .accessibilityIdentifier("role." + roles[i].1)
                    .accessibilityLabel("Peran " + roles[i].1)
                    .accessibilityHint("Buka penjelasan singkat")
                if i < roles.count-1 { Image(systemName:"arrow.right").font(.caption).foregroundStyle(Palette.green.opacity(0.6)).padding(.bottom,25) }
            }
        }.padding(.horizontal,16).frame(maxWidth:.infinity,maxHeight:.infinity)
            .sheet(isPresented:Binding(get:{ selectedRole != nil },set:{ if !$0 { selectedRole = nil } })) {
                NavigationStack {
                    VStack(alignment:.leading,spacing:16) {
                        Text(selectedRole ?? "").font(.system(.title,design:.serif))
                        Text(roleNote(selectedRole ?? "")).font(.body).lineSpacing(4)
                        Spacer(minLength:0)
                    }.padding(26).frame(maxWidth:600,maxHeight:.infinity,alignment:.topLeading)
                        .foregroundStyle(Palette.ink).background(Palette.cream)
                        .toolbar { Button("Tutup") { selectedRole = nil } }
                }.tint(Palette.green).presentationDetents([.height(280),.medium]).presentationDragIndicator(.visible)
            }
    }
    private func roleNote(_ role: String) -> String {
        switch role {
        case "Pengurban": "Orang yang berkurban. Bisa membeli sendiri atau memberi mandat kepada panitia."
        case "Penjual": "Menyediakan hewan dan menyepakati pembelian dengan pengurban atau wakilnya."
        case "Panitia": "Mengoordinasikan pengadaan, pencatatan, pelaksanaan, dan penyaluran sesuai kesepakatan."
        case "Pengantar": "Mengantar hewan ke lokasi yang disepakati untuk serah terima."
        case "Catatan": "Menghubungkan hewan dengan identitas pengurban dan kesepakatan pengadaan."
        case "Perawatan": "Menjaga kebutuhan dan kesejahteraan hewan sebelum pelaksanaan."
        case "Pemeriksaan": "Petugas yang kompeten memeriksa kondisi kesehatan hewan."
        case "Tim", "Pelaksanaan": "Setiap petugas bekerja sesuai peran: persiapan, penyembelihan, pemeriksaan, atau pengolahan."
        case "Area": "Tempat kerja disiapkan agar kegiatan tertata dan kebersihan terjaga."
        case "Kesiapan": "Koordinator memastikan tim, tempat, dan peralatan siap sebelum pelaksanaan."
        case "Pemeriksa": "Memeriksa daging dan organ setelah pemotongan."
        case "Kelayakan": "Petugas menentukan bagian yang layak dan menangani bagian yang tidak layak."
        case "Pengadaan": "Pemilihan, pembelian, pengiriman, dan serah terima hewan."
        case "Penerima": "Menerima paket sesuai pengaturan panitia, termasuk orang yang membutuhkan."
        case "Diantar": "Tim membawa paket kepada penerima dan mencatat penyalurannya."
        case "Diambil": "Penerima datang mengambil paket sesuai pengaturan panitia."
        case "Dicatat": "Penerimaan paket dicatat agar penyaluran dapat ditelusuri."
        default: "Daging yang telah dinyatakan layak disiapkan dan dikemas untuk disalurkan."
        }
    }
}

struct PackingIllustration: View {
    @State private var ready: Set<Int> = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        VStack(spacing:24) {
            Image(systemName:"scalemass").font(.system(size:48,weight:.ultraLight)).foregroundStyle(Palette.green)
            HStack(spacing:12) {
                ForEach(0..<4,id:\.self) { index in
                    Button {
                        withAnimation(reduceMotion ? nil : .spring(duration:0.3,bounce:0.15)) {
                            if ready.contains(index) { ready.remove(index) } else { ready.insert(index) }
                        }
                        UISelectionFeedbackGenerator().selectionChanged()
                    } label: {
                        Image(systemName:ready.contains(index) ? "shippingbox.fill" : "shippingbox")
                            .font(.system(size:29,weight:.light)).foregroundStyle(Palette.green)
                            .frame(width:50,height:56)
                            .background(ready.contains(index) ? Palette.sage : Color.white.opacity(0.6),in:RoundedRectangle(cornerRadius:16))
                            .scaleEffect(ready.contains(index) ? 1.06 : 1)
                    }.buttonStyle(.plain).accessibilityIdentifier("packing.\(index)")
                        .accessibilityLabel("Paket \(index+1)")
                        .accessibilityValue(ready.contains(index) ? "Siap" : "Belum siap")
                        .accessibilityHint("Ketuk untuk mengubah ilustrasi kesiapan paket")
                }
            }
            Text(ready.isEmpty ? "Ketuk paket untuk mencoba" : "Ilustrasi: \(ready.count) dari 4 paket siap")
                .font(.caption.weight(.medium)).accessibilityIdentifier("packing.status")
                .contentTransition(.numericText())
        }
    }
}

@MainActor final class StorySpeaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var speaking = false
    private let synth = AVSpeechSynthesizer()
    override init() { super.init();synth.delegate = self }
    func read(_ text: String) {
        stop()
        try? AVAudioSession.sharedInstance().setCategory(.playback,mode:.spokenAudio,options:.duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        let speech = AVSpeechUtterance(string:text)
        speech.voice = AVSpeechSynthesisVoice(language:"id-ID");speech.rate = 0.47
        speaking = true;synth.speak(speech)
    }
    func stop() {
        synth.stopSpeaking(at:.immediate);speaking = false
        try? AVAudioSession.sharedInstance().setActive(false,options:.notifyOthersOnDeactivation)
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            guard let self,!self.synth.isSpeaking else { return }
            self.speaking = false
            try? AVAudioSession.sharedInstance().setActive(false,options:.notifyOthersOnDeactivation)
        }
    }
}
