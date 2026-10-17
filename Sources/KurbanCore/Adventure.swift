import Foundation

public struct ProcessStation: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let shortTitle: String
    public let symbol: String
    public let story: String
    public let insight: String
    public let optionalExplanation: String?

    public static let all: [ProcessStation] = [
        ProcessStation(id: "check", title: "Hewan diperiksa", shortTitle: "Pemeriksaan", symbol: "heart.text.clipboard.fill",
            story: "Pagi ini, petugas memeriksa hewan. Kamu dan pendamping mengamati dari tempat yang diizinkan panitia.",
            insight: "Pemeriksaan membantu petugas menilai kondisi hewan. Aplikasi dan penonton tidak menggantikan pemeriksaan itu.", optionalExplanation: nil),
        ProcessStation(id: "prepare", title: "Petugas bersiap", shortTitle: "Persiapan", symbol: "person.3.fill",
            story: "Panitia membagi tugas dan menyiapkan area. Ada batas antara tempat kerja petugas dan tempat pengunjung.",
            insight: "Kamu bisa menanyakan tugas panitia kepada pendamping. Penanganan hewan dan alat merupakan tugas petugas.", optionalExplanation: nil),
        ProcessStation(id: "slaughter", title: "Penyembelihan oleh petugas", shortTitle: "Penyembelihan", symbol: "person.fill.checkmark",
            story: "Tahap ini dikerjakan oleh petugas terlatih. Kamu boleh lanjut ke tahap berikutnya tanpa membaca penjelasan tambahan.",
            insight: "Gambaran ini tidak mengajarkan teknik penyembelihan. Pelaksanaan mengikuti ketentuan agama dan prosedur petugas.",
            optionalExplanation: "Pada tahap penyembelihan, hewan dimatikan oleh petugas terlatih untuk kemudian diolah menjadi daging. Kita tidak menampilkan kejadiannya. Kalau kamu sedih atau tidak nyaman, kamu boleh berhenti dan bercerita kepada pendamping."),
        ProcessStation(id: "pack", title: "Ditimbang dan dikemas", shortTitle: "Pengemasan", symbol: "shippingbox.fill",
            story: "Setelah penanganan oleh petugas, panitia menimbang dan mengemas daging menjadi paket. Semuanya dicatat supaya teratur.",
            insight: "Anak dapat belajar melalui pencatatan atau kartu ucapan di area yang disetujui pendamping. Bukan dengan memakai alat potong.", optionalExplanation: nil),
        ProcessStation(id: "deliver", title: "Paket dibagikan", shortTitle: "Pembagian", symbol: "gift.fill",
            story: "Paket disalurkan kepada penerima. Inilah salah satu cara kita belajar peduli. Terima kasih sudah ikut menjelajah!",
            insight: "Penerima dan pembagian mengikuti pengaturan panitia serta ketentuan yang sesuai. Permainan di aplikasi adalah latihan belajar.", optionalExplanation: nil)
    ]
    public static let puzzleOrder = ["deliver", "slaughter", "check", "pack", "prepare"]
}

public struct ProcessOrderingGame: Equatable, Sendable {
    public private(set) var selected: [String] = []
    public init() { }
    public var isFilled: Bool { selected.count == ProcessStation.all.count }
    public var isCorrect: Bool { selected == ProcessStation.all.map(\.id) }
    @discardableResult public mutating func choose(_ id: String) -> Bool {
        guard ProcessStation.all.contains(where: { $0.id == id }), !selected.contains(id) else { return false }
        selected.append(id); return true
    }
    public mutating func undo() { if !selected.isEmpty { selected.removeLast() } }
    public mutating func reset() { selected.removeAll() }
}

public struct SharingGame: Equatable, Sendable {
    public let total: Int
    public private(set) var received: [Int]
    public var remaining: Int { total - received.reduce(0,+) }
    public var isComplete: Bool { remaining == 0 && Set(received).count == 1 }
    public init(stage: LearnerStage) {
        total = stage == .sd ? 6 : 12
        received = Array(repeating: 0, count: stage == .sd ? 3 : 4)
    }
    @discardableResult public mutating func deliver(to index: Int) -> Bool {
        guard received.indices.contains(index), remaining > 0 else { return false }
        received[index] += 1; return true
    }
    @discardableResult public mutating func takeBack(from index: Int) -> Bool {
        guard received.indices.contains(index), received[index] > 0 else { return false }
        received[index] -= 1; return true
    }
    public mutating func reset() { received = Array(repeating:0,count:received.count) }
}
