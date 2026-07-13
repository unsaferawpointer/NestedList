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

	// MARK: - Internal State

	private var bag: AnyCancellable?

	private let provider: SettingsProvider

	// MARK: - Analytics

	private let analytics: any SettingsAnalyticsServiceProtocol

	private var didTrackShow = false

	// MARK: - Initialization

	init(
		provider: SettingsProvider,
		analytics: any SettingsAnalyticsServiceProtocol
	) {
		self.settings = provider.state
		self.provider = provider
		self.analytics = analytics

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

// MARK: - Public Interface
extension SettingsViewModel {

	func show() {
		guard !didTrackShow else {
			return
		}
		didTrackShow = true
		track(.screenShow)
	}

	func click(_ id: SettingsAnalyticsEvent.ButtonIdentifier) {
		track(.buttonClick(id: id))
	}

	func setCompletionBehaviour(isMoveToEnd: Bool) {
		let value: CompletionBehavior = isMoveToEnd ? .moveToEnd : .regular
		guard settings.completionBehaviour != value else {
			return
		}
		settings.completionBehaviour = value
		track(.toggleClick(id: .completionBehaviour, value: isMoveToEnd))
	}

	func setIconColor(_ value: IconColor) {
		guard settings.iconColor != value else {
			return
		}
		settings.iconColor = value
		track(.dropdownItemClick(id: .iconColor, value: value.analyticsValue))
	}
}

// MARK: - Private methods
private extension SettingsViewModel {

	func track(_ event: SettingsAnalyticsEvent) {
		let analytics = analytics
		Task {
			await analytics.track(event)
		}
	}
}

private extension IconColor {

	var analyticsValue: String {
		switch self {
		case .neutral:
			"neutral"
		case .accent:
			"accent"
		case .primary:
			"primary"
		case .multicolor:
			"multicolor"
		}
	}
}
