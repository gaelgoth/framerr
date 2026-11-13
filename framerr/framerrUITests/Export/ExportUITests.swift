import XCTest

final class ExportUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testExportWritesNumberedFilesInGridOrder() {
        let app = XCUIApplication.launchWithSamplePhotos()

        app.photoCell(0).rightClick()
        app.menuItems["Move to End"].click()
        XCTAssertTrue(app.photoCell(2).waitForLabel(containing: "Landscape"))

        app.buttons["Export"].firstMatch.click()

        XCTAssertTrue(app.text(containing: "Exported 3 photos").waitForExistence(timeout: 10))
        XCTAssertTrue(app.text(containing: "“01_Portrait.jpg” to “03_Landscape.jpg”").exists)
        // Scoped to the sheet: a Touch Bar (present on CI VMs) mirrors alert buttons.
        app.sheets.buttons["OK"].click()
    }

    @MainActor
    func testExportingAgainAsksBeforeReplacing() {
        let app = XCUIApplication.launchWithSamplePhotos()
        let export = app.buttons["Export"].firstMatch

        export.click()
        XCTAssertTrue(app.text(containing: "Exported 3 photos").waitForExistence(timeout: 10))
        app.sheets.buttons["OK"].click()

        export.click()
        XCTAssertTrue(app.text(containing: "Replace 3 existing files?").waitForExistence(timeout: 5))
        app.sheets.buttons["Replace"].click()
        XCTAssertTrue(app.text(containing: "Exported 3 photos").waitForExistence(timeout: 10))
    }
}
