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
    var body: some View {
        HStack(spacing:10) {
            ForEach(PurchaseRoute.allCases) { item in
                Button { route = item.rawValue } label: {
                    HStack {
                        Image(systemName:item == .direct ? "person" : "person.2")
                        Text(item.title).fontWeight(.semibold)
                    }.font(.subheadline).frame(maxWidth:.infinity).padding(.vertical,15)
                        .foregroundStyle(route == item.rawValue ? .white : Palette.ink)
                        .background(route == item.rawValue ? Palette.green : .white,in:RoundedRectangle(cornerRadius:17))
                }.buttonStyle(.plain).accessibilityIdentifier("purchase.\(item.rawValue)")
                    .accessibilityAddTraits(route == item.rawValue ? .isSelected : [])
            }
        }
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
    var body: some View {
        HStack(alignment:.center,spacing:3) {
            ForEach(roles.indices,id:\.self) { i in
                RoleToken(symbol:roles[i].0,title:roles[i].1,emphasis:i == 0)
                if i < roles.count-1 { Image(systemName:"arrow.right").font(.caption).foregroundStyle(Palette.green.opacity(0.6)).padding(.bottom,25) }
            }
        }.padding(.horizontal,16).frame(maxWidth:.infinity,maxHeight:.infinity)
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
