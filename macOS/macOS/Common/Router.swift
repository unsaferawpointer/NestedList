//
//  Router.swift
//  Nested List
//
//  Created by Anton Cherkasov on 12.09.2025.
//

import AppKit
import SwiftUI
import CoreModule

protocol RouterProtocol: AnyObject {

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

final class Router {

	unowned var root: NSViewController

	// MARK: - Initialization

	init(root: NSViewController) {
		self.root = root
	}
}

// MARK: - RouterProtocol
extension Router: RouterProtocol {

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
				IconPickerScreen { [weak self] iconName, isSuccess in
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
				ColorPickerScreen { [weak self] color, isSuccess in
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
