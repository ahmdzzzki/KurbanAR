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

    @MainActor private func tapReachable(_ element: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(element.waitForExistence(timeout:5))
        for _ in 0..<6 {
            if element.isHittable { break }
            if element.frame.midY < app.frame.midY { app.swipeDown() } else { app.swipeUp() }
        }
        element.tap()
    }

    @MainActor func testDayJourneyCanSkipOptionalExplanationAndEarnBadge() {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-learning-progress"]
        app.launch()
        app.tabBars.buttons["Hari Kurban"].tap()
        app.buttons["station.slaughter"].tap()
        XCTAssertTrue(app.buttons["day.readOptional"].exists)
        tapReachable(app.buttons["day.next"],in:app)
        XCTAssertEqual(app.staticTexts["day.title"].label,"Ditimbang dan dikemas")
        tapReachable(app.buttons["day.next"],in:app)
        tapReachable(app.buttons["day.next"],in:app)
        for id in ["check","prepare","slaughter","pack","deliver"] {
            tapReachable(app.buttons["order."+id],in:app)
        }
        tapReachable(app.buttons["order.submit"],in:app)
        XCTAssertTrue(app.staticTexts["Urutannya tepat!"].waitForExistence(timeout:5))
        let screenshot = XCTAttachment(screenshot:app.screenshot())
        screenshot.name = "Hari Kurban — tantangan selesai";screenshot.lifetime = .keepAlways;add(screenshot)
    }

    @MainActor func testSharingGameAndSMPMode() {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-learning-progress"]
        app.launch()
        app.tabBars.buttons["Berbagi"].tap()
        for index in 0..<3 {
            tapReachable(app.buttons["family.\(index)"],in:app)
            tapReachable(app.buttons["family.\(index)"],in:app)
        }
        tapReachable(app.buttons["sharing.check"],in:app)
        XCTAssertTrue(app.staticTexts["Hore, semua dapat sama banyak!"].waitForExistence(timeout:5))
        let screenshot = XCTAttachment(screenshot:app.screenshot())
        screenshot.name = "Tantangan berbagi";screenshot.lifetime = .keepAlways;add(screenshot)
        app.swipeDown();app.swipeDown()
        app.buttons["stage.smp"].tap()
        XCTAssertTrue(app.staticTexts["12 paket tersisa"].exists)
        XCTAssertTrue(app.buttons["family.3"].exists)
    }

    @MainActor func testLearningAndPersistence() {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-learning-progress"]
        app.launch()
        app.launchArguments = []
        app.buttons["Mulai misi belajar"].tap()
        let map = XCTAttachment(screenshot:app.screenshot())
        map.name = "Peta misi SD";map.lifetime = .keepAlways;add(map)
        app.staticTexts["Mengenal hewan"].tap()
        XCTAssertTrue(app.buttons["story.read"].exists)
        app.buttons["lesson.next"].tap()
        app.swipeUp()
        app.swipeUp()
        let answer = app.buttons.containing(.staticText, identifier: "Petugas kesehatan hewan").firstMatch
        XCTAssertTrue(answer.waitForExistence(timeout: 5))
        answer.tap()
        app.buttons["Periksa jawaban"].tap()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Hore! Misi selesai."].waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["1 dari 6 bintang"].waitForExistence(timeout: 5))
    }

    @MainActor func testStudioAndDistribution() {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-learning-progress"]
        app.launch()
        app.launchArguments = []
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
        app.tabBars.buttons["Berbagi"].tap()
        tapReachable(app.buttons["sharing.calculator"],in:app)
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
