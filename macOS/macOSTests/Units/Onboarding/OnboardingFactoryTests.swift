//
//  OnboardingFactoryTests.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 08.05.2025.
//

import Testing
import CoreModule
@testable import Nested_List

struct OnboardingFactoryTests {

	@Test func buildForV1_5_0() throws {
		// Arrange
		let sut = OnboardingFactory()

		let item = Item(
			uuid: .random,
			text: .random,
			note: .random
		)

		guard let version = Version(rawValue: "1.5.0") else {
			Issue.record("Cant init version")
			return
		}

		// Act
		let result = try OnboardingFactory.build(for: version)
		#expect(result?.count == 2)

	}
}
