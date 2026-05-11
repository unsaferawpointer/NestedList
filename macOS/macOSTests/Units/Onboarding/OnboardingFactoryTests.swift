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
		guard let version = Version(rawValue: "1.5.0") else {
			Issue.record("Cant init version")
			return
		}

		let result = try OnboardingFactory.build(for: version)

		#expect(result?.count == 2)
	}

	@Test func buildForV2_0_0() throws {
		guard let version = Version(rawValue: "2.0.0") else {
			Issue.record("Cant init version")
			return
		}

		let result = try OnboardingFactory.build(for: version)

		#expect(result?.count == 3)
		#expect(result?.first?.id == "document_format_update")
	}
}
