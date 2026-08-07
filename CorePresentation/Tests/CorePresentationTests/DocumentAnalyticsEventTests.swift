import Analytics
import CoreModule
import Testing
@testable import CorePresentation

struct DocumentAnalyticsEventTests { }

// MARK: - Public Interface
extension DocumentAnalyticsEventTests {

	@Test func read_hasExpectedSchema() {
		let sut = DocumentAnalyticsEvent.read(type: DocumentType.nlist.rawValue)

		#expect(sut.area == "document")
		#expect(sut.name == .documentRead)
		#expect(sut.parameters["type"] == .string(DocumentType.nlist.rawValue))
	}

	@Test func readError_hasExpectedSchema() {
		let sut = DocumentAnalyticsEvent.readError(.unexpectedFormat)

		#expect(sut.area == "document")
		#expect(sut.name == .documentReadError)
		#expect(sut.parameters["reason"] == .string("unexpected_format"))
	}
}
