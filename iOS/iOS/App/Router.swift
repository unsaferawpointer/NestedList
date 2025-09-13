//
//  Router.swift
//  iOS
//
//  Created by Anton Cherkasov on 13.09.2025.
//

import UIKit
import SwiftUI

import DesignSystem
import CoreSettings

protocol RouterProtocol {
	func showDetails(with model: DetailsView.Model, completionHandler: @escaping (DetailsView.Properties, Bool) -> Void)
	func showSettings()
	func hideDetails()
}

final class Router {

	unowned var root: UIViewController

	// MARK: - Initialization

	init(root: UIViewController) {
		self.root = root
	}
}

// MARK: - RouterProtocol
extension Router: RouterProtocol {

	func showDetails(with model: DetailsView.Model, completionHandler: @escaping (DetailsView.Properties, Bool) -> Void) {
		let details = DetailsView(item: model, completionHandler: completionHandler)
		let controller = UIHostingController(rootView: details)
		root.present(controller, animated: true)
	}

	func showSettings() {
		let settings = SettingsView(provider: SettingsProvider.shared)
		let controller = UIHostingController(rootView: settings)
		controller.title = String(localized: "settings-viewcontroller-title", table: "UnitLocalizable")
		let navigationController = UINavigationController(rootViewController: controller)
		root.present(navigationController, animated: true)
	}

	func hideDetails() {
		root.presentedViewController?.dismiss(animated: true)
	}
}
