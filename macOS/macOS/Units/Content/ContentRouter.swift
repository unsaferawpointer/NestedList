//
//  ContentRouter.swift
//  Nested List
//
//  Created by Anton Cherkasov on 12.09.2025.
//

import AppKit
import SwiftUI
import CoreModule
import CorePresentation

protocol ContentRouterProtocol: AnyObject {

	func showDetails(
		with model: ItemDetailsView.Model,
		completionHandler: @escaping (ItemDetailsView.Properties) -> Void
	)

	func showIconPicker(
		navigationTitle: String,
		completionHandler: @escaping @MainActor (IconName?) -> Void
	)

	func showColorPicker(
		navigationTitle: String,
		completionHandler: @escaping @MainActor (ItemColor?) -> Void
	)
}

final class ContentRouter {

	unowned var root: NSViewController

	// MARK: - Initialization

	init(root: NSViewController) {
		self.root = root
	}
}

// MARK: - ContentRouterProtocol
extension ContentRouter: ContentRouterProtocol {

	func showDetails(
		with model: ItemDetailsView.Model,
		completionHandler: @escaping (ItemDetailsView.Properties) -> Void
	) {

		let contentViewController = NSHostingController(
			rootView:
				ItemDetailsView(item: model) { [weak self] properties, isSuccess in
					self?.closeSheet()
					guard isSuccess else {
						return
					}
					completionHandler(properties)
				}
		)
		contentViewController.title = model.navigationTitle
		root.presentAsSheet(contentViewController)
	}

	func showIconPicker(
		navigationTitle: String,
		completionHandler: @escaping @MainActor (IconName?) -> Void
	) {
		let contentViewController = NSHostingController(
			rootView:
				IconPicker(title: navigationTitle) { [weak self] iconName, isSuccess in
					self?.closeSheet()
					guard isSuccess else {
						return
					}
					completionHandler(iconName)
				}
		)
		contentViewController.title = navigationTitle
		root.presentAsSheet(contentViewController)
	}

	func showColorPicker(
		navigationTitle: String,
		completionHandler: @escaping @MainActor (ItemColor?) -> Void
	) {
		let contentViewController = NSHostingController(
			rootView:
				ItemColorPicker(title: navigationTitle) { [weak self] color, isSuccess in
					self?.closeSheet()
					guard isSuccess else {
						return
					}
					completionHandler(color)
				}
		)
		contentViewController.title = navigationTitle
		root.presentAsSheet(contentViewController)
	}

	func closeSheet() {
		if let sheet = root.presentedViewControllers?.last {
			root.dismiss(sheet)
		}
	}
}
