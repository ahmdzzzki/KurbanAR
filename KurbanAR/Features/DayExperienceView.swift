import SwiftUI

struct DayExperienceView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("learnerStage") private var stage = "sd"
    @AppStorage("dayActivityCompleted") private var completed = false
    @StateObject private var speaker = StorySpeaker()
    @State private var station = 0
    @State private var expanded = false
    @State private var showPuzzle = false
    private var current: ProcessStation { ProcessStation.all[station] }
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment:.leading,spacing:22) {
                    KidHeading(kicker:"Sehari bersama panitia",title:"Hari Kurban\nyang penuh makna",detail:"Ikuti kegiatan lewat simbol dan cerita. Tidak ada gambar atau animasi pemotongan.")
                    HStack(spacing:7) {
                        ForEach(ProcessStation.all.indices,id:\.self) { index in
                            Button {
                                speaker.stop();station = index;expanded = false;showPuzzle = false
                            } label: {
                                Image(systemName:ProcessStation.all[index].symbol).font(.headline)
                                    .frame(maxWidth:.infinity).frame(height:47)
                                    .background(station == index ? Palette.sunshine : .white,in:RoundedRectangle(cornerRadius:15))
                            }.buttonStyle(.plain).accessibilityLabel("Tahap \(index+1): \(ProcessStation.all[index].title)")
                                .accessibilityIdentifier("station.\(ProcessStation.all[index].id)")
                        }
                    }
                    if !showPuzzle {
                        VStack(alignment:.leading,spacing:22) {
                            HStack {
                                Text("TAHAP \(station+1) DARI 5").font(.caption.bold()).tracking(1)
                                Spacer()
                                ReadButton(speaker:speaker,text:current.story)
                            }
                            Image(systemName:current.symbol).font(.system(size:62)).foregroundStyle(Palette.green)
                                .frame(maxWidth:.infinity).padding(.vertical,12)
                            Text(current.title).font(.system(.title,design:.rounded).weight(.heavy)).accessibilityIdentifier("day.title")
                            Text(current.story).font(.title3).lineSpacing(5)
                            if let optional = current.optionalExplanation {
                                if expanded {
                                    Text(optional).font(.body).lineSpacing(5).padding(18)
                                        .background(.white.opacity(0.7),in:RoundedRectangle(cornerRadius:18))
                                    ReadButton(speaker:speaker,text:optional)
                                } else {
                                    Button("Baca penjelasan singkat",systemImage:"book") { expanded = true }
                                        .font(.subheadline.bold()).padding(.vertical,10)
                                        .accessibilityIdentifier("day.readOptional")
                                }
                            }
                            if stage == "smp" { Text(current.insight).font(.subheadline).lineSpacing(4).padding(16).background(.white.opacity(0.6),in:RoundedRectangle(cornerRadius:18)) }
                        }.padding(24).frame(maxWidth:.infinity,alignment:.leading)
                            .background(Palette.missionColors[station],in:RoundedRectangle(cornerRadius:28))
                        PrimaryButton(title:station == 4 ? "Coba tantangan urutan" : (current.optionalExplanation != nil ? "Lewati penjelasan, lanjutkan" : "Lanjut ke tahap berikutnya"),symbol:"arrow.right") {
                            speaker.stop()
                            if station < 4 { station += 1;expanded = false } else { showPuzzle = true }
                        }.accessibilityIdentifier("day.next")
                        Label("Boleh penasaran. Boleh juga tidak melihat. Ajak pendamping untuk bertanya dan bercerita.",systemImage:"heart.fill")
                            .font(.footnote).foregroundStyle(Palette.green).lineSpacing(3)
                    } else {
                        ProcessPuzzleView(completed:$completed) { DispatchQueue.main.async { proxy.scrollTo("order.feedback",anchor:.bottom) } }
                    }
                    if completed { Label("Lencana: Penjelajah Hari Kurban",systemImage:"seal.fill").font(.subheadline.bold()).foregroundStyle(Palette.green).paperCard() }
                }.padding(22).frame(maxWidth:700).frame(maxWidth:.infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink)
                .navigationTitle("Hari Kurban").navigationBarTitleDisplayMode(.inline)
                .onDisappear { speaker.stop() }
                .onChange(of:scenePhase) { _,phase in if phase != .active { speaker.stop() } }
            }
        }
    }
}

struct ProcessPuzzleView: View {
    @Binding var completed: Bool
    var onChecked: () -> Void = {}
    @State private var game = ProcessOrderingGame()
    @State private var checked = false
    var body: some View {
        VStack(alignment:.leading,spacing:19) {
            Text("Urutkan perjalanannya!").font(.system(.title2,design:.rounded).weight(.heavy))
            Text("Ketuk kartu sesuai urutan kegiatan, mulai dari yang paling awal.").font(.subheadline).foregroundStyle(.secondary)
            ForEach(Array(game.selected.enumerated()),id:\.element) { index,id in
                if let step = ProcessStation.all.first(where: { $0.id == id }) {
                    HStack { Text("\(index+1)").bold();Image(systemName:step.symbol);Text(step.shortTitle);Spacer() }
                        .padding(15).background(Palette.sage,in:RoundedRectangle(cornerRadius:16))
                }
            }
            ForEach(ProcessStation.puzzleOrder,id:\.self) { id in
                if !game.selected.contains(id), let step = ProcessStation.all.first(where: { $0.id == id }) {
                    Button {
                        _ = game.choose(id);checked = false
                        UISelectionFeedbackGenerator().selectionChanged()
                    } label: {
                        HStack { Image(systemName:step.symbol);Text(step.shortTitle).fontWeight(.semibold);Spacer();Image(systemName:"plus.circle") }
                            .padding(18).background(.white,in:RoundedRectangle(cornerRadius:18))
                    }.buttonStyle(.plain).accessibilityIdentifier("order.\(id)")
                }
            }
            HStack {
                Button("Batalkan satu",systemImage:"arrow.uturn.backward") { game.undo();checked = false }.disabled(game.selected.isEmpty)
                Spacer()
                Button("Ulangi",systemImage:"arrow.clockwise") { game.reset();checked = false }
            }.font(.subheadline).padding(.vertical,8)
            PrimaryButton(title:"Cek urutanku",symbol:"checkmark") {
                checked = true
                if game.isCorrect { completed = true }
                onChecked()
            }.disabled(!game.isFilled).opacity(game.isFilled ? 1 : 0.4).accessibilityIdentifier("order.submit")
            if checked {
                VStack(alignment:.leading,spacing:10) {
                    Label(game.isCorrect ? "Urutannya tepat!" : "Coba mulai dari pemeriksaan hewan.",systemImage:game.isCorrect ? "seal.fill" : "lightbulb.fill").font(.headline)
                    Text(game.isCorrect ? "Kamu sudah mengenal gambaran besar Hari Kurban. Penjelasan tambahan boleh dilewati; lencanamu tetap sama." : "Tak apa. Kamu boleh mengulang cerita, membatalkan kartu, dan mencoba lagi.")
                        .font(.subheadline)
                }.padding(20).background(Palette.sunshine,in:RoundedRectangle(cornerRadius:22))
                    .accessibilityIdentifier("order.feedback").id("order.feedback")
            }
        }
    }
}
