import SwiftUI

enum Palette {
    static let ink = Color(red: 0.12, green: 0.23, blue: 0.19)
    static let green = Color(red: 0.19, green: 0.37, blue: 0.28)
    static let cream = Color(red: 0.97, green: 0.96, blue: 0.92)
    static let sage = Color(red: 0.87, green: 0.91, blue: 0.83)
    static let gold = Color(red: 0.80, green: 0.62, blue: 0.32)
}

struct Eyebrow: View {
    let text: String
    var body: some View {
        Text(text.uppercased()).font(.system(.caption, design: .monospaced).weight(.medium))
            .tracking(2).foregroundStyle(Palette.green)
    }
}

struct PrimaryButton: View {
    let title: String
    var symbol = "arrow.up.right"
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack { Text(title); Spacer(); Image(systemName: symbol) }
                .font(.headline).padding(19).foregroundStyle(.white)
                .background(Palette.green, in: RoundedRectangle(cornerRadius: 20))
        }.buttonStyle(.plain)
    }
}

extension View {
    func paperCard() -> some View {
        self.padding(20).background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 24))
    }
}
