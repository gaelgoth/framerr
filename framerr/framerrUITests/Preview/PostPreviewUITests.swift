import XCTest

final class PostPreviewUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testCarouselPagesThroughPhotosInOrder() {
        let app = XCUIApplication.launchWithSamplePhotos()

        app.radioButtons["Post Preview"].click()

        let counter = app.staticTexts["page-counter"]
        XCTAssertTrue(counter.waitForExistence(timeout: 5))
        XCTAssertTrue(app.text(containing: "your_username").exists)
        XCTAssertTrue(app.text(containing: "1/3").exists)

        let next = app.button(labeled: "Next Photo")
        next.click()
        XCTAssertTrue(app.text(containing: "2/3").waitForExistence(timeout: 5))
        next.click()
        XCTAssertTrue(app.text(containing: "3/3").waitForExistence(timeout: 5))
        XCTAssertFalse(next.exists && next.isEnabled, "no next page after the last photo")

        app.button(labeled: "Previous Photo").click()
        XCTAssertTrue(app.text(containing: "2/3").waitForExistence(timeout: 5))

        app.radioButtons["Arrange"].click()
        XCTAssertTrue(app.photoCell(0).waitForExistence(timeout: 5))
    }
}
