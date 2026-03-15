//
//  Settings.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 10.03.2025.
//

import Foundation
import CoreModule

public struct Settings {

	public var completionBehaviour: CompletionBehavior = .regular

	public var iconColor: IconColor = .neutral

	public var lastOnboardingVersion: OnboardingVersion?

	// MARK: - Initialization

	public init(
		completionBehaviour: CompletionBehavior = .regular,
		iconColor: IconColor = .neutral,
		lastOnboardingVersion: OnboardingVersion? = nil
	) {
		self.completionBehaviour = completionBehaviour
		self.iconColor = iconColor
		self.lastOnboardingVersion = lastOnboardingVersion
	}
}

// MARK: - Equatable
extension Settings: Equatable { }
