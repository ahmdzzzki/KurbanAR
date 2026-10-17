import Foundation

public struct Lesson: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let symbol: String
    public let minutes: Int
    public let paragraphs: [String]
    public let question: String
    public let answers: [String]
    public let correctAnswer: Int
    public let explanation: String

    public static let all: [Lesson] = [
        Lesson(id: "care", title: "Mengenal hewan", subtitle: "Mulai dari kepedulian", symbol: "heart", minutes: 2,
               paragraphs: ["Kurban mengajarkan kepedulian dan berbagi. Mengenal kebutuhan hewan membantu kita memahami tanggung jawab di balik pelaksanaannya.", "Persiapan mencakup perhatian pada kesehatan dan kesejahteraan hewan. Penilaian kelayakan hewan perlu melibatkan petugas yang kompeten; tampilan model 3D bukan alat pemeriksaan.", "Di Studio AR, amati model domba dari berbagai sisi. Model ini dibuat bergaya sederhana dan tidak menunjukkan ukuran, usia, atau kondisi hewan sebenarnya."],
               question: "Siapa yang sebaiknya menilai kesehatan hewan?", answers: ["Cukup melihat model AR", "Petugas kesehatan hewan yang kompeten", "Siapa pun dari foto"], correctAnswer: 1,
               explanation: "Model AR membantu eksplorasi visual. Penilaian kesehatan tetap membutuhkan petugas yang kompeten."),
        Lesson(id: "prepare", title: "Persiapan yang baik", subtitle: "Kenali peran panitia", symbol: "checklist", minutes: 2,
               paragraphs: ["Pelaksanaan kurban memerlukan pembagian tugas yang jelas. Panitia mengatur area, peralatan, pencatatan, dan alur distribusi.", "Penanganan hewan serta pelaksanaan penyembelihan perlu diserahkan kepada petugas terlatih sesuai ketentuan yang berlaku. Aplikasi ini tidak memberikan latihan teknik penyembelihan.", "Sebelum hari pelaksanaan, cari informasi dari panitia setempat dan rujukan resmi. Detail fikih dan kondisi kesehatan hewan perlu dikonsultasikan kepada ahlinya."],
               question: "Apa langkah persiapan yang tepat?", answers: ["Membagi peran panitia dengan jelas", "Mencoba prosedur sendiri dari aplikasi", "Mengabaikan arahan petugas"], correctAnswer: 0,
               explanation: "Pembagian tugas membantu panitia bekerja tertib. Prosedur khusus tetap ditangani petugas terlatih."),
        Lesson(id: "share", title: "Berbagi dengan tertib", subtitle: "Dari timbangan ke penerima", symbol: "shippingbox", minutes: 2,
               paragraphs: ["Penimbangan, pengemasan, dan pencatatan penerima membantu panitia menyiapkan distribusi secara terorganisir.", "Simulasi di aplikasi membagi berat daging siap kemas ke sejumlah paket dengan berat sama. Sisa gram ditampilkan agar seluruh berat tetap tercatat.", "Angka simulasi bukan perkiraan hasil daging dari hewan hidup dan bukan aturan pembagian menurut fikih. Pengaturan penerima dan porsi mengikuti arahan panitia serta rujukan yang sesuai."],
               question: "Apa yang dihitung simulasi distribusi?", answers: ["Berat daging dari hewan hidup", "Ketentuan fikih untuk semua kondisi", "Pembagian berat siap kemas ke paket"], correctAnswer: 2,
               explanation: "Simulasi menghitung pembagian berat siap kemas, lengkap dengan sisanya. Ini latihan aritmetika untuk perencanaan.")
    ]
}

public struct LearningProgress: Equatable, Sendable {
    public private(set) var completed: Set<String>
    public init(saved: String = "") {
        completed = Set(saved.split(separator: ",").map(String.init)).intersection(Set(Lesson.all.map(\.id)))
    }
    public var saved: String { completed.sorted().joined(separator: ",") }
    public var fraction: Double { Double(completed.count) / Double(Lesson.all.count) }
    @discardableResult public mutating func submit(lesson: Lesson, answer: Int) -> Bool {
        guard lesson.answers.indices.contains(answer), answer == lesson.correctAnswer else { return false }
        completed.insert(lesson.id)
        return true
    }
}
