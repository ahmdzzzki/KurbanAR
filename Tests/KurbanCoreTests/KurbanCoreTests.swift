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
@Test func onlyCorrectAnswersPersist() {
    let lesson = Lesson.all[0]
    var progress = LearningProgress(saved: "unknown,care,care")
    #expect(progress.completed == ["care"])
    progress = LearningProgress()
    let invalid = progress.submit(lesson: lesson, answer: -1)
    let wrong = progress.submit(lesson: lesson, answer: 0)
    #expect(!invalid)
    #expect(!wrong)
    #expect(progress.completed.isEmpty)
    let right = progress.submit(lesson: lesson, answer: lesson.correctAnswer)
    let repeated = progress.submit(lesson: lesson, answer: lesson.correctAnswer)
    #expect(right)
    #expect(repeated)
    #expect(progress.completed.count == 1)
    #expect(LearningProgress(saved: progress.saved) == progress)
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

@Test func legacyProgressAndStarsRemainUnique() {
    var progress = LearningProgress(saved:"care,prepare,share,invalid,care")
    #expect(progress.completed.count == 3)
    #expect(progress.fraction == 0.5)
    for lesson in Lesson.all {
        let correct = progress.submit(lesson:lesson,answer:lesson.correctAnswer)
        #expect(correct)
    }
    #expect(progress.completed.count == 6)
    #expect(progress.fraction == 1)
    #expect(progress.badge == "Sahabat Kurban")
    #expect(LearningProgress(saved:progress.saved) == progress)
}
@Test func lessonAndStationCatalogsAreConsistent() {
    #expect(Set(Lesson.all.map(\.id)).count == Lesson.all.count)
    for lesson in Lesson.all { #expect(lesson.answers.indices.contains(lesson.correctAnswer)) }
    #expect(Set(ProcessStation.all.map(\.id)) == Set(ProcessStation.puzzleOrder))
    #expect(ProcessStation.all.filter { $0.optionalExplanation != nil }.map(\.id) == ["slaughter"])
}
@Test func processOrderRejectsInvalidAndDuplicateSteps() {
    var game = ProcessOrderingGame()
    let unknown = game.choose("unknown")
    #expect(!unknown)
    #expect(!game.isCorrect)
    _ = game.choose("deliver")
    let duplicate = game.choose("deliver")
    #expect(!duplicate)
    for step in ProcessStation.all where step.id != "deliver" { _ = game.choose(step.id) }
    #expect(game.isFilled)
    #expect(!game.isCorrect)
    game.reset()
    for step in ProcessStation.all { _ = game.choose(step.id) }
    #expect(game.isCorrect)
    game.undo()
    #expect(!game.isFilled && !game.isCorrect)
}
@Test func sharingConservesPackagesAndRequiresEquality() {
    for stage in LearnerStage.allCases {
        var game = SharingGame(stage:stage)
        let initial = game
        let invalid = game.deliver(to:-1)
        let empty = game.takeBack(from:0)
        #expect(!invalid && !empty)
        #expect(game == initial)
        for _ in 0..<game.total { _ = game.deliver(to:0) }
        #expect(!game.isComplete)
        let extra = game.deliver(to:0)
        #expect(!extra)
        game.reset()
        for _ in 0..<(game.total/game.received.count) {
            for index in game.received.indices {
                _ = game.deliver(to:index)
                #expect(game.remaining + game.received.reduce(0,+) == game.total)
            }
        }
        #expect(game.isComplete)
        _ = game.takeBack(from:0)
        #expect(!game.isComplete && game.remaining == 1)
        _ = game.deliver(to:0)
        #expect(game.isComplete)
    }
}
