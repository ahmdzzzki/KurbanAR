import SwiftUI

enum Palette {
    static let midnight = Color(red:0.075,green:0.13,blue:0.105)
    static let linen = Color(red:0.94,green:0.92,blue:0.83)
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
                .font(.headline).padding(.horizontal,12).frame(minHeight:44).foregroundStyle(.white)
        }.liquidButton(prominent:true)
    }
}

extension View {
    func paperCard() -> some View {
        self.padding(20).background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 24))
    }
}

// Native styles own interaction and hit testing, including accessibility settings.
struct GlassControls<Content: View>: View {
    @ViewBuilder let content: () -> Content
    var body: some View {
        if #available(iOS 26.0, *) { GlassEffectContainer(spacing:12) { content() } }
        else { content() }
    }
}

struct MaterialControlStyle: ButtonStyle {
    var prominent: Bool
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.padding(12)
            .background(prominent ? AnyShapeStyle(Palette.green) : reduceTransparency ? AnyShapeStyle(Color(uiColor:.secondarySystemBackground)) : AnyShapeStyle(.regularMaterial),in:Capsule())
            .opacity(configuration.isPressed ? 0.75 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
    }
}

extension View {
    @ViewBuilder func liquidButton(prominent: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if prominent { self.buttonStyle(.glassProminent).buttonBorderShape(.capsule).tint(Palette.green) }
            else { self.buttonStyle(.glass).buttonBorderShape(.capsule) }
        } else { self.buttonStyle(MaterialControlStyle(prominent:prominent)) }
    }
}
