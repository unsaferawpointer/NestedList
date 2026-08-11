//
//  SoundPlayerMock.swift
//  iOSTests
//
//  Created by Anton Cherkasov on 06.07.2026.
//

import DesignSystem

@MainActor
final class SoundPlayerMock {

	private(set) var invocations: [Action] = []
}

// MARK: - SoundPlayerProtocol
extension SoundPlayerMock: SoundPlayerProtocol {

	func play(sound: Sound) {
		invocations.append(.play(sound))
	}
}

// MARK: - Nested data structs
extension SoundPlayerMock {

	enum Action {
		case play(Sound)
	}
}
