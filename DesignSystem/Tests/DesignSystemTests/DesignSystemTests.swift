import Foundation
import Testing
@testable import DesignSystem

@Test func colorTokenDecodeIfPresent_whenRawValueIsUnknown_returnsNil() throws {
	let json = #"{"color":9}"#.data(using: .utf8) ?? Data()

	let sut = try JSONDecoder().decode(OptionalColorTokenContainer.self, from: json)

	#expect(sut.color == nil)
}

@Test func colorTokenDecodeIfPresent_whenRawValueIsKnown_returnsToken() throws {
	let json = #"{"color":12}"#.data(using: .utf8) ?? Data()

	let sut = try JSONDecoder().decode(OptionalColorTokenContainer.self, from: json)

	#expect(sut.color == .yellow)
}

private struct OptionalColorTokenContainer {
	let color: ColorToken?
}

// MARK: - Decodable
extension OptionalColorTokenContainer: Decodable { }
