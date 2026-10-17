public struct DistributionPlan: Equatable, Sendable {
    public enum ValidationError: Error { case invalidWeight, invalidPackageCount }
    public let totalGrams: Int
    public let packageCount: Int
    public let gramsPerPackage: Int
    public let remainingGrams: Int

    public init(totalGrams: Int, packageCount: Int) throws {
        guard totalGrams > 0 && totalGrams <= 1_000_000 else { throw ValidationError.invalidWeight }
        guard packageCount > 0 && packageCount <= totalGrams else { throw ValidationError.invalidPackageCount }
        self.totalGrams = totalGrams
        self.packageCount = packageCount
        self.gramsPerPackage = totalGrams / packageCount
        self.remainingGrams = totalGrams % packageCount
    }
}
