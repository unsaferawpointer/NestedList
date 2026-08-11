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

	public var soundEffects: SoundEffects = .enabled

	public var lastOnboardingVersion: OnboardingVersion?

	// MARK: - Initialization

	public init(
		completionBehaviour: CompletionBehavior = .regular,
		iconColor: IconColor = .neutral,
		soundEffects: SoundEffects = .enabled,
		lastOnboardingVersion: OnboardingVersion? = nil
	) {
		self.completionBehaviour = completionBehaviour
		self.iconColor = iconColor
		self.soundEffects = soundEffects
		self.lastOnboardingVersion = lastOnboardingVersion
	}
}

// MARK: - Equatable
extension Settings: Equatable { }
