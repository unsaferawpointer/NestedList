//
//  OnboardingFactoryTests.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 12.05.2026.
//

import Testing
import CoreModule
@testable import CorePresentation

struct OnboardingFactoryTests {

	@Test func buildForV1_5_0() throws {
		guard let version = Version(rawValue: "1.5.0") else {
			Issue.record("Cant init version")
			return
		}

		let result = try OnboardingFactory.build(for: version, in: .module)

		#expect(result?.count == 2)
	}

	@Test func buildForV2_0_0() throws {
		guard let version = Version(rawValue: "2.0.0") else {
			Issue.record("Cant init version")
			return
		}

		let result = try OnboardingFactory.build(for: version, in: .module)

		#expect(result?.count == 3)
		#expect(result?.first?.id == "document_format_update")
	}
}
