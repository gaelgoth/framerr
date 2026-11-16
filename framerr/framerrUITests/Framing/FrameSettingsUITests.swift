import XCTest

final class FrameSettingsUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testRatioChangeReframesEveryPhoto() throws {
        let app = XCUIApplication.launchWithSamplePhotos()
        try app.skipUnlessWindowFitsScreen()
        XCTAssertEqual(app.photoCell(0).aspectRatio, 4.0 / 5.0, accuracy: 0.03, "defaults to portrait 4:5")

        app.popUpButtons["ratio-picker"].click()
        app.menuItems["Square 1:1"].click()

        XCTAssertTrue(app.text(containing: "1080 × 1080").waitForExistence(timeout: 5))
        for index in 0 ..< 3 {
            XCTAssertEqual(app.photoCell(index).aspectRatio, 1, accuracy: 0.03)
        }

        app.popUpButtons["ratio-picker"].click()
        app.menuItems["Story 9:16"].click()
        XCTAssertEqual(app.photoCell(0).aspectRatio, 9.0 / 16.0, accuracy: 0.03)
    }

    @MainActor
    func testBorderWidthAndFillTheGap() throws {
        let app = XCUIApplication.launchWithSamplePhotos()
        try app.skipUnlessWindowFitsScreen()
        let slider = app.sliders["border-slider"]

        XCTAssertTrue(app.text(containing: "5%").exists, "defaults to a 5% border")
        // Slider positioning is approximate, so only check the width grew a lot.
        slider.adjust(toNormalizedSliderPosition: 1)
        XCTAssertGreaterThan(Double("\(slider.value ?? 0)") ?? 0, 20)

        let fillGap = app.popUpButtons["fill-gap-picker"]
        fillGap.click()
        app.menuItems["Horizontal Photos"].click()
        XCTAssertTrue(app.text(containing: "Horizontal photos touch the edges").waitForExistence(timeout: 5))
        XCTAssertTrue(slider.isEnabled, "vertical and square photos still get a border")

        fillGap.click()
        app.menuItems["All Photos"].click()
        XCTAssertTrue(app.text(containing: "Every photo touches the edges").waitForExistence(timeout: 5))
        XCTAssertFalse(slider.isEnabled, "border width doesn't apply when every photo fills the gap")

        fillGap.click()
        app.menuItems["Off"].click()
        XCTAssertTrue(app.text(containing: "surrounds every photo on every side").waitForExistence(timeout: 5))
        XCTAssertTrue(slider.isEnabled)
    }
}
