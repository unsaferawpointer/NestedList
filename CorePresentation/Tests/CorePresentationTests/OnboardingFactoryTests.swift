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
		guard let lastVersion = Version(rawValue: "1.0.0") else {
			Issue.record("Cant init version")
			return
		}

		let result = try OnboardingFactory.build(for: version, lastVersion: lastVersion, in: .module)

		#expect(result?.count == 1)
	}

	@Test func buildForV2_0_0() throws {
		guard let version = Version(rawValue: "2.0.0") else {
			Issue.record("Cant init version")
			return
		}
		guard let lastVersion = Version(rawValue: "1.5.0") else {
			Issue.record("Cant init version")
			return
		}

		let result = try OnboardingFactory.build(for: version, lastVersion: lastVersion, in: .module)

		#expect(result?.count == 3)
		#expect(result?.first?.id == "document_format_update")
	}

	@Test func buildForFirstLaunch() throws {
		guard let version = Version(rawValue: "2.0.0") else {
			Issue.record("Cant init version")
			return
		}

		let result = try OnboardingFactory.build(for: version, lastVersion: nil, in: .module)

		#expect(result?.count == 1)
		#expect(result?.first?.id == "premium_features")
	}

	@Test func buildExcludesAlreadyShownFeatures() throws {
		guard let version = Version(rawValue: "2.0.0") else {
			Issue.record("Cant init version")
			return
		}
		guard let lastVersion = Version(rawValue: "2.0.0") else {
			Issue.record("Cant init version")
			return
		}

		let result = try OnboardingFactory.build(for: version, lastVersion: lastVersion, in: .module)

		#expect(result?.isEmpty == true)
	}
}
