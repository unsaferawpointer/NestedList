//
//  SettingsViewModel.swift
//  CoreSettings
//
//  Created by Anton Cherkasov on 13.03.2025.
//

import Foundation
import Combine
import CoreModule

final class SettingsViewModel: ObservableObject {

	@Published var settings: Settings

	var bag: AnyCancellable?

	let provider: SettingsProvider

	init(provider: SettingsProvider) {
		self.settings = provider.state
		self.provider = provider

		bag = $settings.sink { value in
			provider.state = value
		}

		provider.addObservation(for: self) { [weak self] state in
			self?.settings = state
		}
	}

	deinit {
		provider.removeObserver(self)
	}
}
