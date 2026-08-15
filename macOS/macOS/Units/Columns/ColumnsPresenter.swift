//
//  ColumnsPresenter.swift
//  macOS
//

import Foundation
import Analytics
import CoreModule
import CorePresentation
import DesignSystem

@MainActor
protocol ColumnsPresenterProtocol: AnyObject {
	func present(_ ids: [UUID])
}

/// The Columns presenter.
@MainActor
final class ColumnsPresenter {

	private var scrollPosition: UUID?

	private let localization: any ColumnsLocalizationProtocol

	private let analytics: any ConcreteAnalyticsServiceProtocol<ColumnsAnalyticsEvent>

	var interactor: (any ColumnsInteractorProtocol)?

	weak var view: (any ColumnsUnitView)?

	// MARK: - Initialization

	init(
		localization: any ColumnsLocalizationProtocol = ColumnsLocalization(),
		analytics: any ConcreteAnalyticsServiceProtocol<ColumnsAnalyticsEvent> = ConcreteAnalyticsService<ColumnsAnalyticsEvent>()
	) {
		self.localization = localization
		self.analytics = analytics
	}
}

// MARK: - ViewDelegate
extension ColumnsPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard state == .didLoad else {
			return
		}
		Task { await analytics.track(.screenShow) }
		interactor?.fetchData()
	}
}

// MARK: - ColumnsViewOutput
extension ColumnsPresenter: ColumnsViewOutput {

	func handleNewColumnClick() {
		Task { await analytics.track(.buttonClick(id: "new-column")) }
		let id = interactor?.createNewItem(with: localization.newItemText)
		scrollPosition = id
	}
}

// MARK: - ColumnsPresenterProtocol
extension ColumnsPresenter: ColumnsPresenterProtocol {

	func present(_ ids: [UUID]) {
		guard !ids.isEmpty else {
			let placeholderModel: PlaceholderModel = .init(
				icon: "rectangle.split.3x1",
				title: localization.placeholderTitle,
				subtitle: localization.placeholderDescription
			)
			view?.display(state: .placeholder(model: placeholderModel)) { }
			return
		}
		view?.display(state: .columns(ids: ids)) { [weak self] in
			guard let self, let position = scrollPosition else {
				return
			}
			view?.scroll(to: position)
			scrollPosition = nil
		}
	}
}
