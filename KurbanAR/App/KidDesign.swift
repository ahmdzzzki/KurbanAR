import SwiftUI
import AVFoundation

extension Palette {
    static let coral = Color(red:0.92,green:0.48,blue:0.36)
    static let sky = Color(red:0.80,green:0.91,blue:0.95)
    static let lavender = Color(red:0.88,green:0.85,blue:0.96)
    static let sunshine = Color(red:1,green:0.88,blue:0.49)
    static let missionColors = [sage, sunshine, sky, lavender, Color(red:1,green:0.86,blue:0.78),sage]
}

struct StagePicker: View {
    @AppStorage("learnerStage") private var raw = LearnerStage.sd.rawValue
    var body: some View {
        HStack(spacing:10) {
            ForEach(LearnerStage.allCases) { stage in
                Button { raw = stage.rawValue } label: {
                    HStack {
                        Image(systemName:stage == .sd ? "sun.max.fill" : "sparkles")
                        Text(stage.title).fontWeight(.bold)
                        if raw == stage.rawValue { Image(systemName:"checkmark.circle.fill") }
                    }.font(.subheadline).padding(.vertical,13).frame(maxWidth:.infinity)
                        .foregroundStyle(Palette.ink)
                        .background(raw == stage.rawValue ? Palette.sunshine : .white,in:RoundedRectangle(cornerRadius:18))
                        .overlay(RoundedRectangle(cornerRadius:18).stroke(Palette.ink.opacity(0.10)))
                }.buttonStyle(.plain).accessibilityIdentifier("stage.\(stage.rawValue)")
                    .accessibilityAddTraits(raw == stage.rawValue ? .isSelected : [])
            }
        }
    }
}

struct KidHeading: View {
    let kicker: String
    let title: String
    let detail: String
    var body: some View {
        VStack(alignment:.leading,spacing:12) {
            Text(kicker.uppercased()).font(.caption.weight(.bold)).tracking(1.5).foregroundStyle(Palette.green)
            Text(title).font(.system(.largeTitle,design:.rounded).weight(.heavy))
            Text(detail).font(.subheadline).foregroundStyle(.secondary).lineSpacing(3)
        }
    }
}

@MainActor final class StorySpeaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var speaking = false
    private let synth = AVSpeechSynthesizer()
    override init() { super.init(); synth.delegate = self }
    func read(_ text: String) {
        stop()
        try? AVAudioSession.sharedInstance().setCategory(.playback,mode:.spokenAudio,options:.duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        let utterance = AVSpeechUtterance(string:text)
        utterance.voice = AVSpeechSynthesisVoice(language:"id-ID")
        utterance.rate = 0.44
        speaking = true
        synth.speak(utterance)
    }
    func stop() {
        synth.stopSpeaking(at:.immediate);speaking = false
        try? AVAudioSession.sharedInstance().setActive(false,options:.notifyOthersOnDeactivation)
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            guard let self, !self.synth.isSpeaking else { return }
            self.speaking = false
            try? AVAudioSession.sharedInstance().setActive(false,options:.notifyOthersOnDeactivation)
        }
    }
}

struct ReadButton: View {
    @ObservedObject var speaker: StorySpeaker
    let text: String
    var body: some View {
        Button { if speaker.speaking { speaker.stop() } else { speaker.read(text) } } label: {
            Label(speaker.speaking ? "Berhenti" : "Dengarkan",systemImage:speaker.speaking ? "stop.circle.fill" : "speaker.wave.2.fill")
                .font(.subheadline.weight(.semibold)).padding(13)
                .background(.white.opacity(0.85),in:Capsule())
        }.buttonStyle(.plain).accessibilityIdentifier("story.read")
    }
}
