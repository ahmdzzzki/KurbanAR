import Foundation

public enum AnimalSpecies: String, CaseIterable, Identifiable, Sendable {
    case cattle = "sapi"
    case sheep = "domba"
    public var id: String { rawValue }
    public var title: String { self == .cattle ? "Sapi" : "Domba" }
    public var subtitle: String { self == .cattle ? "Sosok kuat, langkah tenang." : "Wol lembut, rasa ingin tahu." }
    public var detail: String { self == .cattle ? "Tanduk · moncong · kuku belah" : "Wol · tanduk melengkung · kuku belah" }
    public var index: String { self == .cattle ? "01" : "02" }
    public var modelHeight: Float { self == .cattle ? 1.55 : 1.05 }
}

public enum AnimalObservation: String, CaseIterable, Identifiable, Sendable {
    case head, body, feet
    public var id: String { rawValue }
    public var title: String {
        switch self { case .head: "Kepala"; case .body: "Tubuh"; case .feet: "Kaki" }
    }
    public func text(for species: AnimalSpecies) -> String {
        switch self {
        case .head: species == .cattle ? "Amati moncong, telinga, dan bentuk tanduk sapi. Bentuknya dapat berbeda antarjenis." : "Lihat telinga dan tanduk yang melengkung. Tidak semua domba memiliki bentuk tanduk yang sama."
        case .body: species == .cattle ? "Sapi memiliki tubuh besar dengan bulu pendek. Putar model untuk membandingkan sisi kiri dan kanannya." : "Lapisan wol menyelimuti tubuh domba. Perhatikan perbedaan permukaan wol dengan wajah dan kakinya."
        case .feet: "Dekatkan tampilan ke kaki. Model memperlihatkan kuku yang terbelah menjadi dua bagian."
        }
    }
}

/// Camera authorization must survive the temporary inactive phase caused by the system's permission dialog.
public enum CameraActivationPolicy {
    public static func shouldActivate(granted: Bool, supported: Bool, isBackground: Bool) -> Bool {
        granted && supported && !isBackground
    }
}
