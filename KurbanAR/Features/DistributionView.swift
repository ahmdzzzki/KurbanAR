import SwiftUI

struct DistributionView: View {
    @State private var kilograms = 25
    @State private var packages = 20
    private var plan: DistributionPlan? {
        try? DistributionPlan(totalGrams: kilograms * 1000, packageCount: packages)
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Eyebrow(text: "Latihan berbagi")
                    Text("Setiap paket,\nsebuah kepedulian.").font(.system(size: 36, weight: .medium, design: .serif))
                    Text("Coba rencanakan pembagian daging siap kemas. Ubah angkanya dan lihat hasilnya.")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 24) {
                        Label("Rencana distribusi", systemImage: "slider.horizontal.3").font(.headline)
                        Stepper(value: $kilograms, in: 1...500) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Berat siap kemas").font(.subheadline)
                                Text("\(kilograms) kg").font(.title2.weight(.semibold))
                            }
                        }
                        Divider()
                        Stepper(value: $packages, in: 1...500) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Jumlah paket").font(.subheadline)
                                Text("\(packages) paket").font(.title2.weight(.semibold))
                            }
                        }
                    }.paperCard()
                    if let plan {
                        VStack(alignment: .leading, spacing: 22) {
                            Image(systemName: "shippingbox").font(.largeTitle)
                            Text("\(plan.gramsPerPackage)")
                                .accessibilityIdentifier("distribution.gramsPerPackage")
                                .font(.system(size: 68, weight: .medium, design: .rounded))
                                .contentTransition(.numericText())
                            Text("gram per paket").font(.title3)
                            Divider().overlay(.white.opacity(0.3))
                            HStack {
                                Label("\(plan.packageCount) paket", systemImage: "checkmark.circle")
                                Spacer()
                                Text("Sisa \(plan.remainingGrams) g")
                            }.font(.subheadline)
                        }.padding(26).frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white).background(Palette.green, in: RoundedRectangle(cornerRadius: 28))
                            .animation(.easeInOut, value: plan)
                        Text("\(plan.packageCount) × \(plan.gramsPerPackage) g + \(plan.remainingGrams) g sisa = \(plan.totalGrams) g")
                            .font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                    Label("Angka ini latihan pembagian berat, bukan ketentuan fikih atau perkiraan hasil daging hewan hidup.", systemImage: "info.circle")
                        .font(.footnote).foregroundStyle(.secondary)
                }.padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity)
            }.background(Palette.cream).foregroundStyle(Palette.ink)
                .navigationTitle("Simulasi distribusi").navigationBarTitleDisplayMode(.inline)
        }
    }
}
