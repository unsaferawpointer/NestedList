//
//  SemanticImageTests.swift
//  DesignSystemTests
//
//  Created by Anton Cherkasov on 05.10.2026.
//

import Testing
@testable import DesignSystem

struct SemanticImageTests { }

// MARK: - SemanticImage
extension SemanticImageTests {

	@Test func linkPoint_returnsCustomLinkCircleImage() {
		// Arrange
		let sut = SemanticImage.linkPoint

		// Act
		let result = sut.image

		// Assert
		#expect(result != nil)
	}
}
