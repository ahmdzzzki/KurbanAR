import Foundation

public enum LearnerStage: String, CaseIterable, Identifiable, Sendable {
    case sd, smp
    public var id: String { rawValue }
    public var title: String { rawValue.uppercased() }
    public var subtitle: String { self == .sd ? "Cerita sederhana" : "Cerita + cari tahu lebih jauh" }
}

public struct Lesson: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let symbol: String
    public let minutes: Int
    public let paragraphs: [String]
    public let insight: String
    public let question: String
    public let answers: [String]
    public let correctAnswer: Int
    public let explanation: String

    public static let all: [Lesson] = [
        Lesson(id: "care", title: "Mengenal hewan", subtitle: "Teman berbulu dan bertanduk", symbol: "pawprint.fill", minutes: 2,
            paragraphs: ["Yuk, kenalan dengan sapi dan domba! Keduanya termasuk hewan yang dapat digunakan untuk kurban. Ada juga jenis hewan lain.", "Hewan perlu dirawat dengan baik. Petugas kesehatan hewan membantu memeriksa kondisinya. Bentuk hewan di layar tidak bisa dipakai untuk menilai kesehatannya."],
            insight: "Memilih hewan kurban melibatkan ketentuan agama dan pemeriksaan kondisi hewan. Bentuk tanduk atau besar tubuh saja tidak cukup untuk menyatakan hewan layak.",
            question: "Siapa yang membantu memeriksa kesehatan hewan?", answers: ["Kita cukup melihat gambarnya", "Petugas kesehatan hewan", "Siapa saja dari jauh"], correctAnswer: 1,
            explanation: "Pemeriksaan dilakukan oleh petugas yang memahami kesehatan hewan."),
        Lesson(id: "meaning", title: "Kenapa kita berkurban?", subtitle: "Syukur, taat, dan peduli", symbol: "heart.fill", minutes: 2,
            paragraphs: ["Saat Iduladha, umat Islam melaksanakan ibadah kurban. Kita belajar bersyukur kepada Allah dan peduli kepada sesama.", "Kurban mengingatkan kita pada keteladanan Nabi Ibrahim dan Nabi Ismail. Daging kurban dibagikan agar manfaatnya dirasakan orang lain."],
            insight: "Makna kurban tidak berhenti pada kegiatan pemotongan. Ada nilai ketaatan, keikhlasan, dan kepedulian sosial. Pelajari kisahnya lebih lanjut bersama guru atau orang tua.",
            question: "Nilai apa yang bisa kita pelajari dari kurban?", answers: ["Peduli dan berbagi", "Berlomba mendapat paling banyak", "Memamerkan milik kita"], correctAnswer: 0,
            explanation: "Kurban mengajak kita bersyukur, taat, dan berbagi manfaat."),
        Lesson(id: "prepare", title: "Siapa melakukan apa?", subtitle: "Kenalan dengan tim panitia", symbol: "person.3.fill", minutes: 2,
            paragraphs: ["Hari kurban terasa ramai! Ada petugas yang memeriksa hewan, menangani hewan, menimbang, dan menyiapkan paket.", "Penyembelihan dilakukan oleh petugas terlatih. Anak-anak bisa belajar dari area pengamatan bersama orang dewasa, sesuai arahan panitia."],
            insight: "Pembagian tugas membantu panitia bekerja teratur. Area penanganan hewan dan alat tajam perlu dipisahkan dari area pengunjung.",
            question: "Siapa yang bertugas melakukan penyembelihan?", answers: ["Petugas yang terlatih", "Anak yang ingin mencoba", "Semua penonton"], correctAnswer: 0,
            explanation: "Itu tugas petugas terlatih. Tugas kita adalah belajar dan mengikuti arahan pendamping."),
        Lesson(id: "observe", title: "Aku boleh melihat?", subtitle: "Penasaran dengan penuh empati", symbol: "eye.fill", minutes: 2,
            paragraphs: ["Penasaran itu wajar. Kalau ingin melihat kegiatan kurban, ajak orang tua atau guru dan ikuti batas area dari panitia. Jangan mendekati alat atau mengganggu hewan.", "Kalau kamu merasa tidak nyaman, kamu boleh menjauh atau tidak melihat. Ceritakan perasaanmu kepada pendamping. Kamu tetap bisa belajar lewat cerita dan kegiatan berbagi."],
            insight: "Setiap orang punya rasa nyaman yang berbeda. Menghormati teman yang tidak ingin melihat sama pentingnya dengan menghargai teman yang ingin bertanya.",
            question: "Temanmu tidak ingin melihat. Apa yang kamu lakukan?", answers: ["Memaksanya supaya berani", "Menghargai dan mengajaknya ke pendamping", "Mengejeknya"], correctAnswer: 1,
            explanation: "Setiap orang boleh memilih. Kita bisa belajar tanpa harus melihat semua proses."),
        Lesson(id: "process", title: "Dari hewan ke paket", subtitle: "Ikuti urutan Hari Kurban", symbol: "arrow.triangle.branch", minutes: 3,
            paragraphs: ["Kegiatan dimulai dengan pemeriksaan hewan dan persiapan petugas. Setelah itu, petugas terlatih melakukan penyembelihan serta penanganan daging.", "Panitia kemudian menimbang, mengemas, dan menyalurkan daging. Di Hari Kurban, kita belajar urutannya lewat simbol dan cerita, tanpa gambar pemotongan."],
            insight: "Ini gambaran besar kegiatan. Pelaksanaan sebenarnya mengikuti ketentuan agama, kesehatan hewan, dan arahan petugas setempat. Aplikasi bukan latihan melakukan penyembelihan.",
            question: "Sebelum paket dibagikan, apa yang dilakukan panitia?", answers: ["Membagikan tanpa persiapan", "Mengajak anak memakai alat tajam", "Menimbang dan mengemas daging"], correctAnswer: 2,
            explanation: "Penimbangan dan pengemasan membantu panitia menyiapkan paket dengan tertib."),
        Lesson(id: "share", title: "Senangnya berbagi", subtitle: "Paket kecil, manfaat besar", symbol: "gift.fill", minutes: 2,
            paragraphs: ["Paket daging disalurkan kepada penerima sesuai pengaturan panitia. Kita belajar peduli dan menghargai orang lain.", "Ayo coba permainan membagi paket sama banyak! Ini latihan berhitung. Pembagian kurban sebenarnya mengikuti arahan panitia dan ketentuan yang sesuai."],
            insight: "Sama banyak dalam permainan membantu kita belajar pembagian. Itu tidak berarti semua situasi kurban harus menggunakan aturan hitung yang sama.",
            question: "Ada 6 paket untuk 3 keluarga dalam permainan. Berapa paket tiap keluarga agar sama banyak?", answers: ["1 paket", "3 paket", "2 paket"], correctAnswer: 2,
            explanation: "6 dibagi 3 sama dengan 2. Setiap keluarga dalam permainan menerima 2 paket.")
    ]
}

public struct LearningProgress: Equatable, Sendable {
    public private(set) var completed: Set<String>
    public init(saved: String = "") {
        completed = Set(saved.split(separator: ",").map(String.init)).intersection(Set(Lesson.all.map(\.id)))
    }
    public var saved: String { completed.sorted().joined(separator: ",") }
    public var fraction: Double { Double(completed.count) / Double(Lesson.all.count) }
    public var badge: String {
        switch completed.count { case 0: "Penjelajah baru"; case 1...2: "Sahabat hewan"; case 3...5: "Penjelajah peduli"; default: "Sahabat Kurban" }
    }
    @discardableResult public mutating func submit(lesson: Lesson, answer: Int) -> Bool {
        guard lesson.answers.indices.contains(answer), answer == lesson.correctAnswer else { return false }
        completed.insert(lesson.id)
        return true
    }
}
