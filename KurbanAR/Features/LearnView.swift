import SwiftUI

struct LearnView: View {
    @AppStorage("completedLessons") private var saved = ""
    private var progress: LearningProgress { LearningProgress(saved: saved) }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Eyebrow(text: "Sedikit demi sedikit")
                    Text("Belajar untuk\nlebih peduli.").font(.system(size: 36, weight: .medium, design: .serif))
                    Text("Tiga bab singkat. Satu perjalanan bermakna.").foregroundStyle(.secondary)
                    ForEach(Array(Lesson.all.enumerated()), id: \.element.id) { index, lesson in
                        NavigationLink {
                            LessonView(lesson: lesson)
                        } label: {
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Image(systemName: lesson.symbol).font(.title2).padding(13)
                                        .background(Palette.sage, in: RoundedRectangle(cornerRadius: 16))
                                    Spacer()
                                    Text("0\(index + 1) / \(lesson.minutes) MENIT").font(.caption.monospaced())
                                }
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(lesson.title).font(.title3.weight(.semibold))
                                        Text(lesson.subtitle).font(.subheadline).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: progress.completed.contains(lesson.id) ? "checkmark.circle.fill" : "arrow.up.right")
                                        .foregroundStyle(Palette.green)
                                }
                            }.paperCard()
                        }.buttonStyle(.plain)
                    }
                    Text("Setiap bab dilengkapi satu pertanyaan refleksi. Progres tersimpan otomatis di perangkatmu.")
                        .font(.footnote).foregroundStyle(.secondary)
                }.padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink).navigationTitle("Perjalanan belajar")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LessonView: View {
    let lesson: Lesson
    @AppStorage("completedLessons") private var saved = ""
    @State private var selected: Int?
    @State private var submitted = false
    private var correct: Bool { selected == lesson.correctAnswer }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: lesson.symbol).font(.largeTitle).foregroundStyle(Palette.green)
                Eyebrow(text: lesson.subtitle)
                Text(lesson.title).font(.system(.largeTitle, design: .serif))
                ForEach(lesson.paragraphs, id: \.self) { text in
                    Text(text).font(.body).lineSpacing(6)
                }
                Divider().padding(.vertical, 8)
                Eyebrow(text: "Cek pemahamanmu")
                Text(lesson.question).font(.title3.weight(.semibold))
                ForEach(lesson.answers.indices, id: \.self) { index in
                    Button {
                        selected = index
                        submitted = false
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: selected == index ? "largecircle.fill.circle" : "circle")
                            Text(lesson.answers[index]).multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }.padding(18)
                            .background(selected == index ? Palette.sage : .white, in: RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain).accessibilityAddTraits(selected == index ? .isSelected : [])
                }
                PrimaryButton(title: "Periksa jawaban", symbol: "checkmark") {
                    guard let selected else { return }
                    var progress = LearningProgress(saved: saved)
                    _ = progress.submit(lesson: lesson, answer: selected)
                    saved = progress.saved
                    submitted = true
                }.disabled(selected == nil).opacity(selected == nil ? 0.45 : 1)
                if submitted {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(correct ? "Tepat! Bab selesai." : "Coba pikirkan lagi.", systemImage: correct ? "checkmark.seal" : "arrow.clockwise")
                            .font(.headline)
                        Text(lesson.explanation).font(.subheadline)
                    }.paperCard().accessibilityElement(children: .combine)
                }
            }.padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity)
        }.background(Palette.cream).foregroundStyle(Palette.ink)
            .navigationBarTitleDisplayMode(.inline)
    }
}
