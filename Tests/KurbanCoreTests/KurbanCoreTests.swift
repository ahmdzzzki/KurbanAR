import Testing
@testable import KurbanCore

@Test func distributionConservesWeight() throws {
    for weight in [1, 999, 10_000, 27_501, 1_000_000] {
        for count in [1, 3, 7, 100].filter({ $0 <= weight }) {
            let plan = try DistributionPlan(totalGrams: weight, packageCount: count)
            #expect(plan.gramsPerPackage * count + plan.remainingGrams == weight)
            #expect(plan.remainingGrams >= 0 && plan.remainingGrams < count)
        }
    }
}
@Test func rejectsInvalidInputs() {
    #expect(throws: DistributionPlan.ValidationError.self) { try DistributionPlan(totalGrams: 0, packageCount: 1) }
    #expect(throws: DistributionPlan.ValidationError.self) { try DistributionPlan(totalGrams: 1_000_001, packageCount: 1) }
    #expect(throws: DistributionPlan.ValidationError.self) { try DistributionPlan(totalGrams: 100, packageCount: 0) }
    #expect(throws: DistributionPlan.ValidationError.self) { try DistributionPlan(totalGrams: 100, packageCount: 101) }
}
@Test func animalCatalogIsComplete() {
    #expect(AnimalSpecies.allCases.count == 2)
    #expect(AnimalSpecies(rawValue: "sapi") == .cattle)
    #expect(AnimalSpecies(rawValue: "domba") == .sheep)
    #expect(AnimalSpecies.cattle.modelHeight > AnimalSpecies.sheep.modelHeight)
    for animal in AnimalSpecies.allCases {
        for point in AnimalObservation.allCases { #expect(!point.text(for: animal).isEmpty) }
    }
}
@Test func cameraPermissionSurvivesInactivePhase() {
    #expect(CameraActivationPolicy.shouldActivate(granted: true, supported: true, isBackground: false))
    #expect(!CameraActivationPolicy.shouldActivate(granted: true, supported: true, isBackground: true))
    #expect(!CameraActivationPolicy.shouldActivate(granted: false, supported: true, isBackground: false))
    #expect(!CameraActivationPolicy.shouldActivate(granted: true, supported: false, isBackground: false))
}


@Test func journeyCoversProcurementThroughDistribution() {
    let ids = JourneyStep.all.map(\.id)
    #expect(ids.count == 10 && Set(ids).count == 10)
    #expect(ids.first == "plan" && ids.last == "distribute")
    #expect(JourneyStep.index(for:"buy") < JourneyStep.index(for:"receive"))
    #expect(JourneyStep.index(for:"care") < JourneyStep.index(for:"slaughter"))
    #expect(JourneyStep.index(for:"slaughter") < JourneyStep.index(for:"inspect"))
    #expect(JourneyStep.index(for:"inspect") < JourneyStep.index(for:"pack"))
    #expect(JourneyStep.index(for:"unknown") == 0)
    for step in JourneyStep.all {
        #expect(step.caption.count <= 100)
        #expect(!step.actor.isEmpty && step.source.scheme == "https")
    }
}
@Test func journeyProgressRejectsUnknownAndDuplicateSteps() {
    var progress = JourneyProgress(saved:"unknown,buy,buy")
    #expect(progress.reviewed == ["buy"])
    let duplicate = progress.review("buy")
    let unknown = progress.review("unknown")
    #expect(!duplicate && !unknown)
    #expect(!progress.isComplete)
    for step in JourneyStep.all { _ = progress.review(step.id) }
    #expect(progress.isComplete)
    #expect(JourneyProgress(saved:progress.saved) == progress)
}
@Test func buyerChangesWithPurchaseRoute() {
    #expect(PurchaseRoute.direct.buyer == "Pengurban")
    #expect(PurchaseRoute.delegated.buyer == "Panitia / lembaga")
    #expect(PurchaseRoute.direct.explanation != PurchaseRoute.delegated.explanation)
}
