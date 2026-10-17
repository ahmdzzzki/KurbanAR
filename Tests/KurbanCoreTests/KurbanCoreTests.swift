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
