import XCTest

final class ImportUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testBulkImportShowsEveryPhotoInOrder() {
        let app = XCUIApplication.launchWithSamplePhotos()

        XCTAssertEqual(app.photoCells.count, 3)
        XCTAssertTrue(app.photoCell(0).label.contains("Landscape"))
        XCTAssertTrue(app.photoCell(1).label.contains("Portrait"))
        XCTAssertTrue(app.photoCell(2).label.contains("Square"))
        XCTAssertFalse(app.staticTexts["No Photos"].exists)
    }

    @MainActor
    func testRemovePhotosBackToEmptyState() {
        let app = XCUIApplication.launchWithSamplePhotos()

        app.photoCell(1).rightClick()
        app.menuItems["Remove"].click()
        XCTAssertEqual(app.photoCells.count, 2)
        XCTAssertTrue(app.photoCell(1).label.contains("Square"))

        app.buttons["Remove All Photos"].firstMatch.click()
        XCTAssertTrue(app.staticTexts["No Photos"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Export"].firstMatch.isEnabled)
    }
}
