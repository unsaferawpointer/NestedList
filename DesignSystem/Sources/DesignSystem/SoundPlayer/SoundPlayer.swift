//
//  SoundPlayer.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.07.2026.
//

import AVFoundation

@MainActor
public protocol SoundPlayerProtocol {
	func play(sound: Sound)
}

@MainActor
public final class SoundPlayer {

	@MainActor
	public static let shared = SoundPlayer()

	private let engine = SoundPlayerEngine()

	// MARK: - Initialization

	private init() {}
}

// MARK: - SoundPlayerProtocol
extension SoundPlayer: SoundPlayerProtocol {

	public func play(sound: Sound) {
		Task {
			await engine.play(sound: sound)
		}
	}
}

// MARK: - Private methods
private actor SoundPlayerEngine {

	private var players = [Sound: AVAudioPlayer]()

	func play(sound: Sound) {
		guard let player = player(for: sound) else {
			return
		}

		player.currentTime = 0
		player.play()
	}

	private func player(for sound: Sound) -> AVAudioPlayer? {
		if let player = players[sound] {
			return player
		}

		let resourceName = sound.name
		guard let url = Bundle.module.url(
			forResource: resourceName,
			withExtension: "wav"
		) else {
			assertionFailure("Sound file not found: \(resourceName).wav")
			return nil
		}

		do {
			let player = try AVAudioPlayer(contentsOf: url)
			player.prepareToPlay()
			players[sound] = player
			return player
		} catch {
			assertionFailure("Failed to prepare sound: \(error)")
			return nil
		}
	}
}
