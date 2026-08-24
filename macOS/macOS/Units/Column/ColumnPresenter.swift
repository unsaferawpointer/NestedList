//
//  ColumnPresenter.swift
//  macOS
//

import Foundation
import CoreModule
import DesignSystem
import CorePresentation

/// The Column presenter interface.
protocol ColumnPresenterProtocol: AnyObject {
	func present(_ item: Item)
}

/// The Column view output interface.
protocol ColumnViewOutput: ViewDelegate, MenuDelegate<ColumnMenuIdentifier> {
	func configure(for id: UUID)
	func plusButtonClicked()
}

final class ColumnPresenter {

	// MARK: - DI

	var interactor: ColumnInteractorProtocol?

	weak var view: ColumnUnitView?

	var router: ContentRouterProtocol

	var localization: ColumnLocalizationProtocol

	private(set) var settingsProvider: any StateProviderProtocol<Settings>

	private let factory: ItemsFactoryProtocol

	private let analytics: any ConcreteAnalyticsServiceProtocol<ColumnAnalyticsEvent>

	// MARK: - Initialization

	init(
		router: ContentRouterProtocol,
		settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared,
		localization: ColumnLocalizationProtocol = ColumnLocalization(),
		factory: ItemsFactoryProtocol = ItemsFactory(),
		analytics: any ConcreteAnalyticsServiceProtocol<ColumnAnalyticsEvent> = ConcreteAnalyticsService<ColumnAnalyticsEvent>()
	) {
		self.router = router
		self.settingsProvider = settingsProvider
		self.localization = localization
		self.factory = factory
		self.analytics = analytics

		settingsProvider.addObservation(for: self) { [weak self] settings in
			self?.interactor?.fetchData()
		}
	}

	deinit {
		settingsProvider.removeObserver(self)
	}
}

// MARK: - ColumnsViewOutput
extension ColumnPresenter: ColumnViewOutput {

	func configure(for id: UUID) {
		interactor?.configure(for: id)
	}

	func viewDidChange(state: ViewState) {
		guard state == .didLoad else {
			return
		}
		interactor?.fetchData()
	}

	func plusButtonClicked() {
		let properties = ItemProperties(text: localization.newItemText)
		let target = view?.selection.first
		interactor?.newItem(with: properties, target: target)
	}
}

// MARK: - MenuDelegate
extension ColumnPresenter: MenuDelegate {

	func menuItemClicked(_ item: ColumnMenuIdentifier, source: MenuSource) {
		trackMenuItemClick(item)

		switch item {
		case .columnNew:
			let properties = ItemProperties(text: localization.newItemText)
			let target = view?.selection.first
			interactor?.newItem(with: properties, target: target)
		case .columnEdit:
			guard let item = interactor?.rootItem() else {
				return
			}
			let model = ItemDetailsView.Model(
				navigationTitle: localization.editItemDetailsTitle,
				properties: item.details
			)
			router.showDetails(with: model) { [weak self] saved in
				let note = saved.description.isEmpty ? nil : saved.description
				self?.interactor?.set(saved.text, note: note)
			}
		case .columnDelete:
			interactor?.deleteColumn()
		case .toggleStrikethrough:
			let moveToEnd = settingsProvider.state.completionBehaviour == .moveToEnd
			interactor?.toggleStrikethrough(moveToEnd: moveToEnd)
		case .changeIcon:
			router.showIconPicker(navigationTitle: localization.iconPickerNavigationTitle) { [weak self] iconName in
				self?.interactor?.setIcon(iconName)
			}
		case .changeColor:
			router.showColorPicker(navigationTitle: localization.colorPickerNavigationTitle) { [weak self] color in
				self?.interactor?.setColor(color)
			}
		case .moveForward:
			interactor?.moveForward()
		case .moveBackward:
			interactor?.moveBackward()
		case .appearanceHeader, .separator:
			fatalError()
		}
	}

	func validateMenuItem(_ item: ColumnMenuIdentifier) -> Bool {
		switch item {
		case .moveForward:
			interactor?.validateMovingForward() ?? false
		case .moveBackward:
			interactor?.validateMovingBackward() ?? false
		case .appearanceHeader, .separator:
			false
		default:
			true
		}
	}

	func isHidden(_ item: ColumnMenuIdentifier) -> Bool {
		return false
	}

	func stateForMenuItem(_ item: ColumnMenuIdentifier) -> ControlState {
		switch item {
		case .toggleStrikethrough:
			interactor?.isStrikethrough() == true ? .on : .off
		default:
			.off
		}
	}

	func menuItems() -> [ColumnMenuIdentifier] {
		return [
			.columnEdit,
			.separator,
			.toggleStrikethrough,
			.separator,
			.appearanceHeader,
			.changeIcon,
			.changeColor,
			.separator,
			.moveForward,
			.moveBackward,
			.separator,
			.columnDelete
		]
	}
}

// MARK: - ColumnsPresenterProtocol
extension ColumnPresenter: ColumnPresenterProtocol {

	func present(_ item: Item) {
		let itemModel = factory.makeItem(item: item, isLeaf: false, iconColor: settingsProvider.state.iconColor)
		let model = ColumnModel(title: item.text, configuration: itemModel.configuration)
		view?.display(model)
	}
}

private extension ColumnPresenter {

	func trackMenuItemClick(_ item: ColumnMenuIdentifier) {
		Task {
			await analytics.track(.menuItemClick(id: item.rawValue))
		}
	}
}

private extension Item {

	var details: ItemDetailsView.Properties {
		return .init(text: text, description: note ?? "")
	}
}
