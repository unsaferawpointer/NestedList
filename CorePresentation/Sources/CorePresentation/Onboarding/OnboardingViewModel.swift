//
//  OnboardingViewModel.swift
//  CorePresentation
//
//  Created by Codex on 13.07.2026.
//

import Foundation

@Observable
final class OnboardingViewModel {

	private(set) var state: OnboardingState

	private(set) var isCompleted = false

	// MARK: - Analytics

	private let analytics: any OnboardingAnalyticsServiceProtocol

	private var didTrackShow = false

	// MARK: - Initialization

	init(
		features: [Feature],
		analytics: any OnboardingAnalyticsServiceProtocol
	) {
		self.state = .init(features: features)
		self.analytics = analytics
	}
}

// MARK: - Public Interface
extension OnboardingViewModel {

	var features: [Feature] {
		return state.features
	}

	var currentPage: Int {
		get {
			return state.currentPage
		}
		set {
			state.currentPage = newValue
		}
	}

	var feature: Feature {
		return state.feature
	}

	var pageIndices: Range<Int> {
		return state.features.indices
	}

	var id: String {
		return state.id
	}

	func show() {
		guard !didTrackShow else {
			return
		}
		didTrackShow = true
		track(.screenShow(totalCount: state.features.count))
	}

	func back() {
		guard state.canBack else {
			return
		}
		track(.buttonClick(button: .back, index: state.currentPage))
		state.back()
	}

	func skip() {
		track(.buttonClick(button: .skip, index: state.currentPage))
		complete()
	}

	func primaryAction() {
		if state.canNext {
			state.next()
		} else {
			track(.buttonClick(button: .getStarted, index: state.currentPage))
			complete()
		}
	}
}

// MARK: - Private methods
private extension OnboardingViewModel {

	func complete() {
		guard !isCompleted else {
			return
		}
		isCompleted = true
	}

	func track(_ event: OnboardingAnalyticsEvent) {
		let analytics = analytics
		Task {
			await analytics.track(event)
		}
	}
}

struct OnboardingState {

	let features: [Feature]
	var currentPage: Int

	// MARK: - Initialization

	init(features: [Feature]) {
		assert(!features.isEmpty, "Features list is empty")
		self.features = features
		self.currentPage = 0
	}
}

// MARK: - Public Interface
extension OnboardingState {

	var feature: Feature {
		return features[currentPage]
	}

	var canNext: Bool {
		return currentPage < features.count - 1
	}

	var canBack: Bool {
		return currentPage > 0
	}

	var id: String {
		return feature.id
	}

	mutating func next() {
		guard canNext else {
			return
		}
		currentPage += 1
	}

	mutating func back() {
		guard canBack else {
			return
		}
		currentPage -= 1
	}
}
