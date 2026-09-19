import Analytics
import Testing
@testable import CorePresentation

struct ContentAnalyticsEventTests { }

// MARK: - Public Interface
extension ContentAnalyticsEventTests {

	#if os(macOS)
	@Test func inlineEditFinish_withNote_hasExpectedSchema() {
		// Arrange
		let sut = ContentAnalyticsEvent.inlineEditFinish(titleLength: 12, noteLength: 8)

		// Act
		let parameters = sut.parameters

		// Assert
		#expect(sut.area == "content")
		#expect(sut.name == .inlineEditFinish)
		#expect(parameters["title_length"] == .int(12))
		#expect(parameters["note_length"] == .int(8))
	}

	@Test func inlineEditFinish_withoutNote_omitsNoteLength() {
		// Arrange
		let sut = ContentAnalyticsEvent.inlineEditFinish(titleLength: 12, noteLength: nil)

		// Act
		let parameters = sut.parameters

		// Assert
		#expect(parameters["title_length"] == .int(12))
		#expect(parameters["note_length"] == nil)
	}
	#endif
}
