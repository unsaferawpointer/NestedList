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

		if #available(iOS 26.0, *) {
			if let barItem, let toolbarItem = root.toolbarItems?.first(where: { $0.identifier == barItem} ) {
				controller.preferredTransition = .zoom { context in
					return toolbarItem
				}
			}
		}

		root.present(controller, animated: true)
	}

	func showSettings() {
		let settings = SettingsView(provider: SettingsProvider.shared)
		let controller = UIHostingController(rootView: settings)
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
		root.present(controller, animated: true)
	}

	func dismiss() {
		root.presentedViewController?.dismiss(animated: true)
	}
}
