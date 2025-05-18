//
//  OnboardingFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 03.05.2025.
//

import Foundation
import CoreModule
import DesignSystem

final class OnboardingFactory { }

extension OnboardingFactory {

	static func build(for version: Version) throws -> [Page]? {
		let bundle = Bundle.main
		guard
			let path = bundle.url(forResource: "onboarding-\(version.rawValue)", withExtension: "json"),
			let data = try? Data(contentsOf: path)
		else {
			return nil
		}

		return try JSONDecoder().decode([Page].self, from: data)
	}
}
