//
//  SettingsViewModel.swift
//  Nested List
//
//  Created by Anton Cherkasov on 10.03.2025.
//

import Foundation
import Combine
import CoreModule

final class SettingsViewModel: ObservableObject {

	@Published var settings: Settings

	var bag: AnyCancellable?

	init(provider: SettingsProvider) {
		self.settings = provider.state

		bag = $settings.sink { value in
			provider.state = value
		}

		provider.addObservation(for: self) { [weak self] _, state in
			self?.settings = state
		}
	}
}
