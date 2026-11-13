import XCTest

extension XCUIApplication {
    /// Launches with three sample photos imported (Landscape, Portrait, Square) and a temp export folder.
    static func launchWithSamplePhotos() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        XCTAssertTrue(app.photoCells.element(boundBy: 2).waitForExistence(timeout: 10), "sample photos imported")
        return app
    }

    var photoCells: XCUIElementQuery {
        descendants(matching: .any).matching(identifier: "photo-cell")
    }

    func photoCell(_ index: Int) -> XCUIElement {
        photoCells.element(boundBy: index)
    }

    /// Matches by label; SwiftUI uses the SF Symbol name as identifier for icon buttons.
    func button(labeled label: String) -> XCUIElement {
        buttons.matching(NSPredicate(format: "label == %@", label)).firstMatch
    }

    /// Static text whose label or value contains `text`.
    func text(containing text: String) -> XCUIElement {
        staticTexts.matching(NSPredicate(format: "label CONTAINS %@ OR value CONTAINS %@", text, text)).firstMatch
    }
}

extension XCUIElement {
    var aspectRatio: CGFloat {
        frame.width / frame.height
    }

    func waitForLabel(containing text: String, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        return XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: predicate, object: self)], timeout: timeout) == .completed
    }
}
