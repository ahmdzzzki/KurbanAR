import SwiftUI

struct DistributionView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var kilograms = 25
    @State private var packages = 20
    private var plan: DistributionPlan? { try? DistributionPlan(totalGrams:kilograms*1000,packageCount:packages) }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:24) {
                    Text("Dari timbangan\nke dalam paket.").font(.system(.largeTitle,design:.serif))
                    HStack(spacing:18) {
                        Image(systemName:"scalemass").font(.system(size:40,weight:.ultraLight))
                        Image(systemName:"arrow.right").foregroundStyle(.secondary)
                        Image(systemName:"shippingbox").font(.system(size:40,weight:.ultraLight))
                    }.foregroundStyle(Palette.green).frame(maxWidth:.infinity).padding(28).background(Palette.mist,in:RoundedRectangle(cornerRadius:25))
                    VStack(spacing:24) {
                        Stepper(value:$kilograms,in:1...500) { VStack(alignment:.leading,spacing:5) { Text("Daging siap kemas").font(.caption);Text("\(kilograms) kg").font(.title2.weight(.medium)) } }.accessibilityIdentifier("calculator.weight")
                        Divider()
                        Stepper(value:$packages,in:1...500) { VStack(alignment:.leading,spacing:5) { Text("Jumlah paket").font(.caption);Text("\(packages) paket").font(.title2.weight(.medium)) } }.accessibilityIdentifier("calculator.packages")
                    }.paperCard()
                    if let plan {
                        VStack(alignment:.leading,spacing:12) {
                            Text("\(plan.gramsPerPackage)").font(.system(size:58,weight:.light,design:.rounded)).accessibilityIdentifier("distribution.gramsPerPackage").contentTransition(.numericText())
                                .animation(reduceMotion ? nil : .smooth(duration:0.25),value:plan.gramsPerPackage)
                            Text("gram per paket").font(.subheadline)
                            Divider()
                            Text("Sisa \(plan.remainingGrams) g").font(.caption)
                        }.padding(25).frame(maxWidth:.infinity,alignment:.leading).foregroundStyle(.white).background(Palette.green,in:RoundedRectangle(cornerRadius:25))
                        Text("Contoh hitung, bukan aturan pembagian.").font(.footnote).foregroundStyle(.secondary)
                        DisclosureGroup("Rincian hitungan") {
                            Text("\(plan.packageCount) × \(plan.gramsPerPackage) g + \(plan.remainingGrams) g = \(plan.totalGrams) g").font(.caption.monospaced()).padding(.vertical,10)
                        }.font(.subheadline)
                    }
                }.padding(24).frame(maxWidth:700).frame(maxWidth:.infinity)
            }.sensoryFeedback(.selection,trigger:kilograms).sensoryFeedback(.selection,trigger:packages).background(Palette.cream).foregroundStyle(Palette.ink).navigationTitle("Hitung paket").navigationBarTitleDisplayMode(.inline)
        }
    }
}
