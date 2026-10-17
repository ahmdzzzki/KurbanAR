import Foundation

public enum PurchaseRoute: String, CaseIterable, Identifiable, Sendable {
    case direct, delegated
    public var id: String { rawValue }
    public var title: String { self == .direct ? "Beli sendiri" : "Titip panitia" }
    public var buyer: String { self == .direct ? "Pengurban" : "Panitia / lembaga" }
    public var explanation: String {
        self == .direct ? "Pengurban membeli hewan, lalu menyerahkannya kepada penyelenggara." : "Pengurban memberi mandat. Panitia atau lembaga membeli sesuai kesepakatan."
    }
}

public enum DeliveryRoute: String, CaseIterable, Identifiable, Sendable {
    case deliver, collect
    public var id: String { rawValue }
    public var title: String { self == .deliver ? "Diantar" : "Diambil" }
}

public struct JourneyStep: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let caption: String
    public let actor: String
    public let symbol: String
    public let detail: String
    public let source: URL
    private static let farming = URL(string:"https://www.pertanian.go.id/home/?act=view&id=7754&show=news")!
    private static let delegation = URL(string:"https://storage.nu.or.id/storage/archive/panduan-fiqh-kurban-lbm-pwnu-jateng_1657016594.pdf")!
    private static let distribution = URL(string:"https://dki.kemenag.go.id/berita/panitia-qurban-kankemenag-jakarta-utara-matangkan-distribusi-daging-kurban-pEvCv")!
    public static let all: [JourneyStep] = [
        .init(id:"plan",title:"Mulai dari pengurban",caption:"Tentukan hewan, anggaran, dan siapa yang mengurus.",actor:"Pengurban",symbol:"person.crop.circle",detail:"Pengurban adalah orang yang berkurban. Pengadaan dan pelaksanaan dapat diurus langsung atau diwakilkan sesuai kesepakatan.",source:delegation),
        .init(id:"choose",title:"Pilih hewannya",caption:"Jenis hewan dipilih. Kelayakannya perlu diperiksa.",actor:"Pengurban · penjual · petugas",symbol:"pawprint",detail:"Sapi dan domba adalah dua contoh dalam aplikasi. Jenis, usia, kondisi, dan ketentuan hewan perlu dikonfirmasi kepada penyelenggara serta petugas; model 3D tidak menilai kelayakan.",source:farming),
        .init(id:"buy",title:"Siapa yang membeli?",caption:"Pembelian mengikuti jalur yang dipilih di awal.",actor:"Pembeli · penjual",symbol:"receipt",detail:"Jalur beli sendiri: pengurban bertransaksi dengan penjual. Jalur titip: wakil yang diberi mandat membelikan hewan. Identitas pengurban, hewan, dan biaya yang disepakati dicatat.",source:delegation),
        .init(id:"receive",title:"Hewan diserahterimakan",caption:"Hewan tiba dan dicocokkan dengan catatan pengurban.",actor:"Pengantar · panitia",symbol:"truck.box",detail:"Pengiriman dan serah terima diatur antara penjual, pengurban, dan penyelenggara. Panitia memastikan hewan dan pencatatannya sesuai.",source:delegation),
        .init(id:"care",title:"Dirawat dan diperiksa",caption:"Kebutuhan hewan dijaga. Kondisinya diperiksa petugas.",actor:"Perawat · petugas kesehatan hewan",symbol:"heart.text.clipboard",detail:"Sebelum penyembelihan, ada perhatian pada kesejahteraan hewan dan pemeriksaan kesehatan. Penilaian serta tindak lanjut merupakan tugas petugas yang kompeten.",source:farming),
        .init(id:"prepare",title:"Pelaksanaan disiapkan",caption:"Tim, tempat, dan peralatan siap sesuai peran.",actor:"Koordinator · petugas",symbol:"person.3",detail:"Penyelenggara menyiapkan pembagian tugas, area kerja, kebersihan, dan pencatatan. Susunan kegiatan dapat berbeda antarpenyelenggara.",source:farming),
        .init(id:"slaughter",title:"Penyembelihan",caption:"Dilakukan petugas terlatih sesuai ketentuan.",actor:"Petugas penyembelihan",symbol:"person.fill.checkmark",detail:"Hewan disembelih oleh petugas terlatih. Aplikasi menampilkan tahap ini secara simbolis dan tidak mengajarkan teknik penyembelihan.",source:farming),
        .init(id:"inspect",title:"Daging diperiksa",caption:"Sesudah pemotongan, daging dan organ diperiksa.",actor:"Petugas pemeriksa",symbol:"checkmark.shield",detail:"Pemeriksaan setelah pemotongan membantu petugas menentukan kelayakan daging dan organ. Keputusan mengenai bagian yang tidak layak ditangani oleh petugas.",source:farming),
        .init(id:"pack",title:"Ditimbang dan dikemas",caption:"Daging dipotong, ditimbang, lalu dikemas.",actor:"Tim timbang · tim kemas",symbol:"scalemass",detail:"Setelah dinyatakan layak, daging dipisahkan dari tulang dan dipotong oleh tim pengolahan. Panitia menimbang, mengemas, dan mencatat paket untuk penyaluran. Contoh gram di aplikasi hanyalah hitungan pembagian berat siap kemas, bukan ketentuan fikih atau hasil dari berat hewan hidup.",source:distribution),
        .init(id:"distribute",title:"Sampai ke penerima",caption:"Paket disalurkan dan penerimaannya dicatat.",actor:"Tim distribusi · penerima",symbol:"shippingbox",detail:"Panitia mengatur penerima, termasuk orang yang membutuhkan, sesuai ketentuan dan kesepakatan. Paket dapat diantar atau diambil sesuai pengaturan setempat; tidak semua pembagian harus sama berat.",source:distribution)
    ]
    public static func index(for id: String) -> Int { all.firstIndex(where: { $0.id == id }) ?? 0 }
}

public struct JourneyProgress: Equatable, Sendable {
    public private(set) var reviewed: Set<String>
    public init(saved: String = "") {
        reviewed = Set(saved.split(separator:",").map(String.init)).intersection(Set(JourneyStep.all.map(\.id)))
    }
    public var saved: String { reviewed.sorted().joined(separator:",") }
    public var isComplete: Bool { reviewed.count == JourneyStep.all.count }
    @discardableResult public mutating func review(_ id: String) -> Bool {
        guard JourneyStep.all.contains(where: { $0.id == id }) else { return false }
        return reviewed.insert(id).inserted
    }
}
