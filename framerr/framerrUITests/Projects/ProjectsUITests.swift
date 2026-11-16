import XCTest

final class ProjectsUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSaveAsProjectMovesTheUnsavedPostIntoAProject() throws {
        let app = XCUIApplication.launchWithSamplePhotos()
        try app.skipUnlessWindowFitsScreen()
        XCTAssertEqual(app.projectRows.count, 0, "projects are optional")
        XCTAssertTrue(app.text(containing: "Save a post as a project").exists, "the sidebar explains projects")

        app.popUpButtons["ratio-picker"].click()
        app.menuItems["Square 1:1"].click()

        app.button(labeled: "Save as Project…").click()
        let title = app.textFields["project-title-field"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "asks for a title")
        title.typeKey("a", modifierFlags: .command)
        title.typeText("Summer")
        app.button(labeled: "Create").click()

        XCTAssertTrue(app.outlines.staticTexts["Summer"].waitForExistence(timeout: 5), "the sidebar shows the new project")
        XCTAssertTrue(app.photoCell(2).waitForExistence(timeout: 10), "the photos moved into the project")
        XCTAssertTrue(app.text(containing: "1080 × 1080").exists, "and so did the settings")

        app.unsavedRow.click()
        XCTAssertTrue(app.text(containing: "No Photos").waitForExistence(timeout: 5), "the unsaved post starts over")
        XCTAssertTrue(app.text(containing: "1080 × 1350").exists)
    }

    @MainActor
    func testNewProjectStartsEmptyWithItsOwnSettings() throws {
        let app = XCUIApplication.launchWithSamplePhotos()
        try app.skipUnlessWindowFitsScreen()

        app.button(labeled: "New Project").click()
        let title = app.textFields["project-title-field"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.typeText("Winter\r")

        XCTAssertTrue(app.outlines.staticTexts["Winter"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.text(containing: "No Photos").waitForExistence(timeout: 5), "a new project starts empty and is selected")
        app.popUpButtons["ratio-picker"].click()
        app.menuItems["Square 1:1"].click()
        XCTAssertTrue(app.text(containing: "1080 × 1080").waitForExistence(timeout: 5))

        app.unsavedRow.click()
        XCTAssertTrue(app.photoCell(2).waitForExistence(timeout: 5), "the unsaved post kept its photos")
        XCTAssertEqual(app.photoCell(0).aspectRatio, 4.0 / 5.0, accuracy: 0.03, "and its own ratio")
    }

    @MainActor
    func testCancelAddsNothingAndRenameUpdatesTheSidebar() {
        let app = XCUIApplication.launchWithSamplePhotos()

        app.button(labeled: "New Project").click()
        XCTAssertTrue(app.textFields["project-title-field"].waitForExistence(timeout: 5))
        app.button(labeled: "Cancel").click()
        XCTAssertEqual(app.projectRows.count, 0, "cancel leaves nothing behind")

        app.button(labeled: "New Project").click()
        app.textFields["project-title-field"].typeText("Draft\r")
        XCTAssertTrue(app.outlines.staticTexts["Draft"].waitForExistence(timeout: 5))

        app.projectRows.element(boundBy: 0).rightClick()
        app.menuItems["Rename…"].click()
        let title = app.textFields["project-title-field"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.typeKey("a", modifierFlags: .command)
        title.typeText("Spring\r")
        XCTAssertTrue(app.outlines.staticTexts["Spring"].waitForExistence(timeout: 5))
    }
}
