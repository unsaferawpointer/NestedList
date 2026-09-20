//
//  DocumentRouter.swift
//  iOS
//
//  Created by Codex on 20.09.2026.
//

import UIKit
import SwiftUI

import CorePresentation

@MainActor
protocol DocumentRouterProtocol {
	func showSettings()
}

@MainActor
final class DocumentRouter {

	unowned var root: UIViewController

	private let analytics: any ConcreteAnalyticsServiceProtocol<DocumentAnalyticsEvent>
	private let localization: DocumentLocalizationProtocol = DocumentLocalization()

	// MARK: - Initialization

	init(
		root: UIViewController,
		analytics: any ConcreteAnalyticsServiceProtocol<DocumentAnalyticsEvent> =
			ConcreteAnalyticsService<DocumentAnalyticsEvent>()
	) {
		self.root = root
		self.analytics = analytics
	}
}

// MARK: - DocumentRouterProtocol
extension DocumentRouter: DocumentRouterProtocol {

	func showSettings() {
		Task { await analytics.track(.buttonClick(id: "settings")) }

		let settings = SettingsView(provider: SettingsProvider.shared)
		let controller = UIHostingController(rootView: settings)
		controller.modalPresentationStyle = .formSheet
		controller.title = localization.settingsViewControllerTitle
		let navigationController = UINavigationController(rootViewController: controller)
		root.present(navigationController, animated: true)
	}
}
