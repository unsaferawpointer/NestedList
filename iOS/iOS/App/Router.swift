//
//  ContentRouter.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.09.2025.
//

import UIKit
import SwiftUI

import CoreModule
import CorePresentation
import CoreSettings

@MainActor
protocol RouterProtocol {
	func showDetails(
		with model: ItemDetailsView.Model,
		animateBottomBarItem barItem: String?,
		completionHandler: @escaping @MainActor (ItemDetailsView.Properties, Bool) -> Void
	)
	func showSettings()
	func showTargetsScreen(for ids: Set<UUID>, completionHandler: @escaping (UUID?, Bool) -> Void)
	func showReorderScreen(for item: UUID, completionHandler: @escaping () -> Void)
	func showIconPicker(title: String, completionHandler: @escaping @MainActor (IconName?) -> Void)
	func showColorPicker(title: String, completionHandler: @escaping @MainActor (ItemColor?) -> Void)
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

// MARK: - ContentRouterProtocol
extension Router: RouterProtocol {

	func showDetails(
		with model: ItemDetailsView.Model,
		animateBottomBarItem barItem: String?,
		completionHandler: @escaping @MainActor (ItemDetailsView.Properties, Bool) -> Void
	) {
		let details = ItemDetailsView(item: model, completionHandler: completionHandler)
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

	func showIconPicker(title: String, completionHandler: @escaping @MainActor (IconName?) -> Void) {

		let picker = IconPicker(title: title) { [weak self] icon, isSuccess in
			self?.root.presentedViewController?.dismiss(animated: true)
			guard isSuccess else {
				return
			}
			completionHandler(icon)
		}

		let controller = UIHostingController(rootView: picker)
		controller.modalPresentationStyle = .formSheet
		controller.title = title

		if let sheet = controller.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
		}

		root.present(controller, animated: true)
	}

	func showColorPicker(title: String, completionHandler: @escaping @MainActor (ItemColor?) -> Void) {

		let picker = ItemColorPicker(title: title) { [weak self] token, isSuccess in
			self?.root.presentedViewController?.dismiss(animated: true)
			guard isSuccess else {
				return
			}
			completionHandler(token)
		}

		let controller = UIHostingController(rootView: picker)
		controller.modalPresentationStyle = .formSheet
		controller.title = title

		if let sheet = controller.sheetPresentationController {
			sheet.detents = [.medium()]
		}

		root.present(controller, animated: true)
	}

	func dismiss() {
		root.presentedViewController?.dismiss(animated: true)
	}
}
