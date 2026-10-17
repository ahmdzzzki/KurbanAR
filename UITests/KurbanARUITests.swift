import XCTest

final class KurbanARUITests: XCTestCase {
    @MainActor func testLearningAndPersistence() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Belajar"].tap()
        app.staticTexts["Mengenal hewan"].tap()
        app.swipeUp()
        app.swipeUp()
        let answer = app.buttons.containing(.staticText, identifier: "Petugas kesehatan hewan yang kompeten").firstMatch
        XCTAssertTrue(answer.waitForExistence(timeout: 5))
        answer.tap()
        app.buttons["Periksa jawaban"].tap()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Tepat! Bab selesai."].waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["1 dari 3 bab selesai"].waitForExistence(timeout: 5))
    }

    @MainActor func testStudioAndDistribution() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Studio AR"].tap()
        XCTAssertTrue(app.staticTexts["PREVIEW 3D"].waitForExistence(timeout: 5))
        let preview = XCTAttachment(screenshot: app.screenshot())
        preview.name = "Studio 3D"
        preview.lifetime = .keepAlways
        add(preview)
        app.tabBars.buttons["Distribusi"].tap()
        let weight = app.staticTexts["distribution.gramsPerPackage"]
        XCTAssertTrue(weight.waitForExistence(timeout: 5))
        XCTAssertEqual(weight.label.filter(\.isNumber), "1250")
        XCTAssertTrue(app.staticTexts["Sisa 0 g"].exists)
        let distribution = XCTAttachment(screenshot: app.screenshot())
        distribution.name = "Distribusi"
        distribution.lifetime = .keepAlways
        add(distribution)
    }
}
