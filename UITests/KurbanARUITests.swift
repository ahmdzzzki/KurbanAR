import XCTest

final class KurbanARUITests: XCTestCase {
    @MainActor private func waitForVisibleExhibit(_ app: XCUIApplication) {
        let visible = NSPredicate { _, _ in
            guard let cg = app.screenshot().image.cgImage,
                  let bytes = cg.dataProvider?.data,
                  let data = CFDataGetBytePtr(bytes), cg.bitsPerPixel == 32 else { return false }
            var bright = 0
            for yi in 0..<9 {
                for xi in 0..<13 {
                    let x = Int(Double(cg.width) * (0.2 + Double(xi) * 0.05))
                    let y = Int(Double(cg.height) * (0.35 + Double(yi) * 0.03))
                    let i = y * cg.bytesPerRow + x * 4
                    if max(data[i],data[i+1],data[i+2]) > 105 { bright += 1 }
                }
            }
            return bright > 12
        }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate:visible,object:nil)],timeout:25),.completed,
                       "The exhibit must render visible geometry, not just load its model.")
    }

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
        XCTAssertTrue(app.staticTexts["STUDIO 3D"].waitForExistence(timeout: 5))
        app.buttons["animal.sapi"].tap()
        XCTAssertEqual(app.staticTexts["studio.animalName"].label, "Sapi")
        let renderReady = NSPredicate(format: "label CONTAINS %@", "Geser satu jari")
        expectation(for: renderReady, evaluatedWith: app.staticTexts["studio.status"])
        waitForExpectations(timeout: 25)
        waitForVisibleExhibit(app)
        let cow = XCTAttachment(screenshot: app.screenshot())
        cow.name = "Studio sapi"; cow.lifetime = .keepAlways; add(cow)
        app.buttons["animal.domba"].tap()
        XCTAssertEqual(app.staticTexts["studio.animalName"].label, "Domba")
        app.buttons["observation.body"].tap()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format:"label CONTAINS %@", "Lapisan wol")).firstMatch.exists)
        app.buttons["Tutup pengamatan"].tap()
        app.buttons["studio.camera"].tap()
        XCTAssertTrue(app.staticTexts["Kamera AR perlu perangkat fisik"].waitForExistence(timeout: 5))
        app.buttons["Selesai"].tap()
        expectation(for: renderReady, evaluatedWith: app.staticTexts["studio.status"])
        waitForExpectations(timeout: 25)
        waitForVisibleExhibit(app)
        let preview = XCTAttachment(screenshot: app.screenshot())
        preview.name = "Studio 3D"
        preview.lifetime = .keepAlways
        add(preview)
        app.buttons["Kembali ke beranda"].tap()
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
