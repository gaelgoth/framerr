import Testing
@testable import framerr

struct ExportNamingTests {
    @Test func prefixesTwoDigitOrderNumber() {
        #expect(ExportNaming.fileNames(for: ["IMG_0012", "DSC 4"]) == ["01_IMG_0012.jpg", "02_DSC 4.jpg"])
    }

    @Test func widensNumbersSoFilesStillSortInOrder() {
        let names = ExportNaming.fileNames(for: Array(repeating: "x", count: 120))
        #expect(names.first == "001_x.jpg")
        #expect(names.last == "120_x.jpg")
        #expect(names == names.sorted())
    }
}
