import XCTest

final class ReorderUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testContextMenuReordersPhotos() {
        let app = XCUIApplication.launchWithSamplePhotos()

        app.photoCell(0).rightClick()
        app.menuItems["Move Later"].click()
        XCTAssertTrue(app.photoCell(0).waitForLabel(containing: "Portrait"))
        XCTAssertTrue(app.photoCell(1).label.contains("Photo 2 of 3, Landscape"))

        app.photoCell(2).rightClick()
        app.menuItems["Move to Start"].click()
        XCTAssertTrue(app.photoCell(0).waitForLabel(containing: "Square"))
        XCTAssertTrue(app.photoCell(1).label.contains("Portrait"))
        XCTAssertTrue(app.photoCell(2).label.contains("Landscape"))
    }

    @MainActor
    func testDragAndDropReordersPhotos() {
        let app = XCUIApplication.launchWithSamplePhotos()

        let center = CGVector(dx: 0.5, dy: 0.5)
        app.photoCell(0).coordinate(withNormalizedOffset: center)
            .click(forDuration: 0.5, thenDragTo: app.photoCell(2).coordinate(withNormalizedOffset: center))

        XCTAssertTrue(app.photoCell(2).waitForLabel(containing: "Landscape"))
        XCTAssertTrue(app.photoCell(0).label.contains("Portrait"))
    }
}
