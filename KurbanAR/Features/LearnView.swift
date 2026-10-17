import SwiftUI

struct LearnView: View {
    @AppStorage("completedLessons") private var saved = ""
    @AppStorage("learnerStage") private var stageRaw = LearnerStage.sd.rawValue
    private var progress: LearningProgress { LearningProgress(saved:saved) }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:23) {
                    KidHeading(kicker:"Petualangan kurban",title:"Misi kecil,\npelajaran besar!",detail:"Baca atau dengarkan cerita, lalu coba pertanyaannya. Kamu boleh mulai dari mana saja.")
                    StagePicker()
                    Text(stageRaw == "sd" ? "Mode SD · cerita pendek dan bahasa sederhana" : "Mode SMP · cerita pendek dengan penjelasan tambahan")
                        .font(.caption).foregroundStyle(.secondary)
                    HStack(spacing:15) {
                        Image(systemName:"star.circle.fill").font(.system(size:43)).foregroundStyle(Palette.gold)
                        VStack(alignment:.leading,spacing:5) {
                            Text("\(progress.completed.count) / \(Lesson.all.count) bintang").font(.title3.bold()).accessibilityIdentifier("missions.progress")
                            Text(progress.badge).font(.subheadline)
                        }
                        Spacer()
                    }.padding(20).background(Palette.sunshine.opacity(0.45),in:RoundedRectangle(cornerRadius:24))
                    ForEach(Array(Lesson.all.enumerated()),id:\.element.id) { index,lesson in
                        NavigationLink { LessonView(lesson:lesson) } label: {
                            HStack(spacing:17) {
                                Image(systemName:lesson.symbol).font(.title2).frame(width:58,height:64)
                                    .background(Palette.missionColors[index],in:RoundedRectangle(cornerRadius:19))
                                VStack(alignment:.leading,spacing:7) {
                                    Text("MISI \(index+1) · \(lesson.minutes) MENIT").font(.system(size:10,weight:.bold,design:.rounded)).foregroundStyle(.secondary)
                                    Text(lesson.title).font(.system(.headline,design:.rounded))
                                    Text(lesson.subtitle).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer(minLength:0)
                                Image(systemName:progress.completed.contains(lesson.id) ? "star.fill" : "chevron.right")
                                    .foregroundStyle(progress.completed.contains(lesson.id) ? Palette.gold : Palette.green)
                            }.padding(15).background(.white,in:RoundedRectangle(cornerRadius:24))
                        }.buttonStyle(.plain).accessibilityIdentifier("lesson.\(lesson.id)")
                    }
                    Label("Bintang untuk belajar, bukan lomba. Ulangi kapan pun kamu mau.",systemImage:"heart.fill")
                        .font(.footnote).foregroundStyle(Palette.green).padding(.bottom,16)
                }.padding(22).frame(maxWidth:700).frame(maxWidth:.infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink)
                .navigationTitle("Misi belajar").navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LessonView: View {
    let lesson: Lesson
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("completedLessons") private var saved = ""
    @AppStorage("learnerStage") private var stageRaw = LearnerStage.sd.rawValue
    @StateObject private var speaker = StorySpeaker()
    @State private var page = 0
    @State private var selected: Int?
    @State private var submitted = false
    @State private var newStar = false
    private var correct: Bool { selected == lesson.correctAnswer }
    private var lastPage: Bool { page == lesson.paragraphs.count-1 }
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment:.leading,spacing:22) {
                    HStack {
                        Text("CERITA \(page+1) / \(lesson.paragraphs.count)").font(.caption.weight(.bold)).tracking(1)
                        Spacer()
                        ReadButton(speaker:speaker,text:lesson.title+". "+lesson.paragraphs[page])
                    }
                    ProgressView(value:Double(page+1),total:Double(lesson.paragraphs.count)).tint(Palette.green)
                    VStack(alignment:.leading,spacing:22) {
                        Image(systemName:lesson.symbol).font(.system(size:46)).foregroundStyle(Palette.green)
                        Text(lesson.title).font(.system(.title,design:.rounded).weight(.heavy))
                        Text(lesson.paragraphs[page]).font(.title3).lineSpacing(6)
                    }.padding(25).frame(maxWidth:.infinity,alignment:.leading)
                        .background(Palette.sunshine.opacity(0.45),in:RoundedRectangle(cornerRadius:28)).id("story.top")
                    if stageRaw == "smp" && lastPage {
                        VStack(alignment:.leading,spacing:10) {
                            Label("Cari tahu lebih jauh",systemImage:"sparkles").font(.headline)
                            Text(lesson.insight).font(.subheadline).lineSpacing(4)
                            ReadButton(speaker:speaker,text:lesson.insight)
                        }.padding(20).background(Palette.sky,in:RoundedRectangle(cornerRadius:22))
                    }
                    if !lastPage {
                        PrimaryButton(title:"Lanjut ceritanya",symbol:"arrow.right") {
                            speaker.stop();page = min(page+1,lesson.paragraphs.count-1)
                            proxy.scrollTo("story.top",anchor:.top)
                        }.accessibilityIdentifier("lesson.next")
                    } else {
                        VStack(alignment:.leading,spacing:17) {
                            Label("Sekarang giliranmu!",systemImage:"lightbulb.fill").font(.headline).foregroundStyle(Palette.green)
                            Text(lesson.question).font(.system(.title3,design:.rounded).weight(.bold))
                            ForEach(lesson.answers.indices,id:\.self) { index in
                                Button {
                                    selected = index;submitted = false
                                    UISelectionFeedbackGenerator().selectionChanged()
                                } label: {
                                    HStack(spacing:13) {
                                        Image(systemName:selected == index ? "checkmark.circle.fill" : "circle")
                                        Text(lesson.answers[index]).multilineTextAlignment(.leading)
                                        Spacer(minLength:0)
                                    }.font(.body).padding(18)
                                        .background(selected == index ? Palette.sage : .white,in:RoundedRectangle(cornerRadius:20))
                                }.buttonStyle(.plain).accessibilityIdentifier("answer.\(index)")
                                    .accessibilityAddTraits(selected == index ? .isSelected : [])
                            }
                            PrimaryButton(title:"Periksa jawaban",symbol:"checkmark") {
                                guard let selected else { return }
                                speaker.stop()
                                var progress = LearningProgress(saved:saved)
                                let alreadyEarned = progress.completed.contains(lesson.id)
                                let accepted = progress.submit(lesson:lesson,answer:selected)
                                newStar = accepted && !alreadyEarned
                                saved = progress.saved;submitted = true
                                DispatchQueue.main.async { proxy.scrollTo("lesson.feedback",anchor:.bottom) }
                            }.disabled(selected == nil).opacity(selected == nil ? 0.45 : 1)
                            if submitted {
                                VStack(alignment:.leading,spacing:12) {
                                    Image(systemName:correct ? "star.circle.fill" : "lightbulb.fill").font(.largeTitle).foregroundStyle(Palette.green)
                                    Text(correct ? "Hore! Misi selesai." : "Yuk, coba lagi.").font(.system(.title3,design:.rounded).weight(.bold))
                                    Text(lesson.explanation).font(.subheadline).lineSpacing(3)
                                    if correct { Text(newStar ? "+1 bintang untuk petualanganmu" : "Bintang misi ini sudah kamu dapatkan.").font(.caption.bold()) }
                                }.padding(22).frame(maxWidth:.infinity,alignment:.leading)
                                    .background(correct ? Palette.sunshine : Palette.sky,in:RoundedRectangle(cornerRadius:24))
                                    .accessibilityIdentifier("lesson.feedback").id("lesson.feedback")
                            }
                        }.id("quiz")
                    }
                    if page > 0 {
                        Button("Baca bagian sebelumnya",systemImage:"arrow.left") { speaker.stop();page = max(0,page-1);proxy.scrollTo("story.top",anchor:.top) }
                            .font(.subheadline).padding(.vertical,12)
                    }
                }.padding(22).frame(maxWidth:700).frame(maxWidth:.infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink)
        }.navigationBarTitleDisplayMode(.inline)
            .onDisappear { speaker.stop() }
            .onChange(of:scenePhase) { _,phase in if phase != .active { speaker.stop() } }
    }
}
