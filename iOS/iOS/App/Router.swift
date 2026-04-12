//
//  Router.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.09.2025.
//

import UIKit
import SwiftUI

import CoreModule
import DesignSystem
import CoreSettings

protocol RouterProtocol {
	func showDetails(
		with model: DetailsView.Model,
		animateBottomBarItem barItem: String?,
		completionHandler: @escaping (DetailsView.Properties, Bool) -> Void
	)
	func showSettings()
	func showTargetsScreen(for ids: Set<UUID>, completionHandler: @escaping (UUID?, Bool) -> Void)
	func showReorderScreen(for item: UUID, completionHandler: @escaping () -> Void)
	func showIconPicker(completionHandler: @escaping @MainActor (IconName?) -> Void)
	func showColorPicker(completionHandler: @escaping @MainActor (ItemColor?) -> Void)
	func dismiss()
}

final class Router {

	unowned var root: UIViewController

	unowned var storage: DocumentStorage<Content>

	// MARK: - Initialization

	init(root: UIViewController, storage: DocumentStorage<Content>) {
		self.root = root
		self.storage = storage
	}
}

// MARK: - RouterProtocol
extension Router: RouterProtocol {

	func showDetails(
		with model: DetailsView.Model,
		animateBottomBarItem barItem: String?,
		completionHandler: @escaping (DetailsView.Properties, Bool) -> Void
	) {
		let details = DetailsView(item: model, completionHandler: completionHandler)
		let controller = UIHostingController(rootView: details)
		controller.modalPresentationStyle = .formSheet

		if #available(iOS 26.0, *) {
			if let barItem, let toolbarItem = root.toolbarItems?.first(where: { $0.identifier == barItem} ) {
				controller.preferredTransition = .zoom { context in
					return toolbarItem
				}
			}
		}
		if let sheet = controller.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
		}

		root.present(controller, animated: true)
	}

	func showSettings() {
		let settings = SettingsView(provider: SettingsProvider.shared)
		let controller = UIHostingController(rootView: settings)
		controller.modalPresentationStyle = .formSheet
		controller.title = String(localized: "settings-viewcontroller-title", table: "UnitLocalizable")
		let navigationController = UINavigationController(rootViewController: controller)
		root.present(navigationController, animated: true)
	}

	func showTargetsScreen(for ids: Set<UUID>, completionHandler: @escaping (UUID?, Bool) -> Void) {
		let controller = UIHostingController(
			rootView: TargetDestionationView(
				storage: storage,
				movingItems: ids,
				completionHandler: completionHandler
			)
		)
		controller.modalPresentationStyle = .formSheet
		root.present(controller, animated: true)
	}

	func showReorderScreen(for item: UUID, completionHandler: @escaping () -> Void) {
		let controller = UIHostingController(
			rootView: ReorderView(
				item: item,
				storage: storage,
				completionHandler: completionHandler
			)
		)
		controller.modalPresentationStyle = .formSheet
		root.present(controller, animated: true)
	}

	func showIconPicker(completionHandler: @escaping @MainActor (IconName?) -> Void) {

		let picker = IconPickerScreen { [weak self] icon in
			completionHandler(icon)
			self?.root.presentedViewController?.dismiss(animated: true)
		}

		let controller = UIHostingController(rootView: picker)
		controller.modalPresentationStyle = .formSheet

		if let sheet = controller.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
		}

		root.present(controller, animated: true)
	}

	func showColorPicker(completionHandler: @escaping @MainActor (ItemColor?) -> Void) {

		let picker = ColorPickerScreen { [weak self] token in
			completionHandler(token)
			self?.root.presentedViewController?.dismiss(animated: true)
		}

		let controller = UIHostingController(rootView: picker)
		controller.modalPresentationStyle = .formSheet

		if let sheet = controller.sheetPresentationController {
			sheet.detents = [.medium()]
		}

		root.present(controller, animated: true)
	}

	func dismiss() {
		root.presentedViewController?.dismiss(animated: true)
	}
}
