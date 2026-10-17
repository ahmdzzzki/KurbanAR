import XCTest

final class KurbanARUITests: XCTestCase {
    @MainActor private func openFresh() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-journey"]
        app.launch()
        app.launchArguments = []
        return app
    }
    @MainActor private func tapReachable(_ element: XCUIElement,in app: XCUIApplication) {
        for _ in 0..<5 {
            if element.exists { break }
            app.swipeUp()
        }
        XCTAssertTrue(element.waitForExistence(timeout:5))
        for _ in 0..<6 {
            if element.isHittable { break }
            if element.frame.midY < app.frame.midY { app.swipeDown() } else { app.swipeUp() }
        }
        element.tap()
    }
    @MainActor private func save(_ name: String,_ app: XCUIApplication) {
        RunLoop.current.run(until:Date().addingTimeInterval(0.5))
        let a = XCTAttachment(screenshot:app.screenshot());a.name = name;a.lifetime = .keepAlways;add(a)
    }
    @MainActor func testBuyerRoutesAndAnimalChoicePersist() {
        let app = openFresh()
        XCTAssertEqual(app.tabBars.buttons.count,3)
        tapReachable(app.buttons["purchase.delegated"],in:app)
        save("01 — Siapa yang mengurus",app)
        app.buttons["journey.next"].tap()
        XCTAssertEqual(app.staticTexts["journey.title"].label,"Pilih hewannya")
        tapReachable(app.buttons["journey.animal.domba"],in:app)
        app.buttons["journey.next"].tap()
        XCTAssertEqual(app.staticTexts["journey.caption"].label,"Panitia atau lembaga membeli atas mandat pengurban.")
        save("03 — Pembelian diwakilkan",app)
        tapReachable(app.buttons["purchase.direct"],in:app)
        XCTAssertEqual(app.staticTexts["journey.caption"].label,"Pengurban membeli langsung dari penjual.")
        app.terminate();app.launch()
        XCTAssertEqual(app.staticTexts["journey.title"].label,"Siapa yang membeli?")
        XCTAssertEqual(app.staticTexts["journey.caption"].label,"Pengurban membeli langsung dari penjual.")
    }
    @MainActor func testEndToEndJourneyAndDeliveryChoice() {
        let app = openFresh()
        let titles = ["Mulai dari pengurban","Pilih hewannya","Siapa yang membeli?","Hewan diserahterimakan","Dirawat dan diperiksa","Pelaksanaan disiapkan","Penyembelihan","Daging diperiksa","Ditimbang dan dikemas","Sampai ke penerima"]
        for (index,title) in titles.enumerated() {
            XCTAssertEqual(app.staticTexts["journey.title"].label,title)
            if index == 7 { save("08 — Pemeriksaan daging",app) }
            if index == 9 {
                tapReachable(app.segmentedControls.buttons["Diambil"],in:app)
                XCTAssertEqual(app.staticTexts["journey.caption"].label,"Penerima mengambil paket sesuai pengaturan panitia.")
                save("10 — Sampai ke penerima",app)
            }
            app.buttons["journey.next"].tap()
        }
        XCTAssertTrue(app.staticTexts["Satu perjalanan.\nBanyak peran."].waitForExistence(timeout:5))
        save("Perjalanan lengkap",app)
    }
    @MainActor func testMapDetailCalculatorAndStudio() {
        let app = openFresh()
        app.buttons["journey.map"].tap()
        tapReachable(app.buttons["jump.inspect"],in:app)
        XCTAssertEqual(app.staticTexts["journey.title"].label,"Daging diperiksa")
        tapReachable(app.buttons["journey.detail"],in:app)
        XCTAssertTrue(app.staticTexts["Petugas pemeriksa"].exists)
        app.buttons["Tutup"].tap()
        app.tabBars.buttons["Hitung"].tap()
        XCTAssertTrue(app.staticTexts["distribution.gramsPerPackage"].waitForExistence(timeout:5))
        XCTAssertEqual(app.staticTexts["distribution.gramsPerPackage"].label.filter(\.isNumber),"1250")
        app.tabBars.buttons["Hewan"].tap()
        XCTAssertTrue(app.staticTexts["STUDIO 3D"].waitForExistence(timeout:5))
        app.buttons["animal.sapi"].tap()
        XCTAssertEqual(app.staticTexts["studio.animalName"].label,"Sapi")
        app.buttons["animal.domba"].tap()
        XCTAssertEqual(app.staticTexts["studio.animalName"].label,"Domba")
        save("Studio Liquid Glass",app)
        app.buttons["Kembali ke beranda"].tap()
        XCTAssertTrue(app.staticTexts["journey.title"].exists)
    }
    @MainActor func testSwipeRolesPackingAndLiveCalculator() {
        let app = openFresh()
        app.buttons["role.Pengurban"].tap()
        XCTAssertTrue(app.staticTexts["Orang yang berkurban. Bisa membeli sendiri atau memberi mandat kepada panitia."].waitForExistence(timeout:5))
        save("Peran tanpa menambah isi layar",app)
        app.buttons["Tutup"].tap()
        let illustration = app.otherElements["journey.visual"]
        illustration.swipeLeft()
        XCTAssertEqual(app.staticTexts["journey.title"].label,"Pilih hewannya")
        // The same gesture rotates the animal instead of accidentally changing stages.
        illustration.swipeLeft()
        XCTAssertEqual(app.staticTexts["journey.title"].label,"Pilih hewannya")
        app.buttons["journey.next"].tap()
        illustration.swipeRight()
        XCTAssertEqual(app.staticTexts["journey.title"].label,"Pilih hewannya")
        app.buttons["journey.map"].tap()
        tapReachable(app.buttons["jump.pack"],in:app)
        for i in 0..<4 { app.buttons["packing.\(i)"].tap() }
        XCTAssertEqual(app.staticTexts["packing.status"].label,"Ilustrasi: 4 dari 4 paket siap")
        XCTAssertEqual(app.buttons["packing.0"].value as? String,"Siap")
        app.buttons["packing.0"].tap()
        XCTAssertEqual(app.staticTexts["packing.status"].label,"Ilustrasi: 3 dari 4 paket siap")
        save("Interaksi paket",app)
        app.tabBars.buttons["Hitung"].tap()
        let packages = app.steppers["calculator.packages"]
        packages.buttons.element(boundBy:1).tap()
        XCTAssertEqual(app.staticTexts["distribution.gramsPerPackage"].label.filter(\.isNumber),"1190")
        save("Hitung paket langsung",app)
    }

}
