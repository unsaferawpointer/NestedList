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

@MainActor protocol ContentRouterProtocol: AnyObject {

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

	func showDocument(for id: UUID) -> Void
}

final class ContentRouter {

	unowned var root: NSViewController

	private let storage: DocumentStorage<Content>

	// MARK: - Initialization

	init(root: NSViewController, storage: DocumentStorage<Content>) {
		self.root = root
		self.storage = storage
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

	func showDocument(for id: UUID) {
		guard let parentWindow = root.view.window else {
			return
		}

		let contentViewController = ContentUnitAssembly.build(for: id, storage: storage)
		let childWindow = NSWindow(contentViewController: contentViewController)
		childWindow.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
		childWindow.titleVisibility = .visible
		childWindow.titlebarAppearsTransparent = false
		childWindow.isReleasedWhenClosed = false
		childWindow.setContentSize(parentWindow.frame.size)
		childWindow.setFrameOrigin(
			NSPoint(
				x: parentWindow.frame.origin.x + 24,
				y: parentWindow.frame.origin.y - 24
			)
		)

		let windowController = DocumentChildWindowController(window: childWindow)
		if let document = NSDocumentController.shared.document(for: parentWindow) {
			windowController.documentOwner = document
			document.addWindowController(windowController)
		}

		parentWindow.addChildWindow(childWindow, ordered: .above)
		childWindow.makeKeyAndOrderFront(nil)
	}

	func closeSheet() {
		if let sheet = root.presentedViewControllers?.last {
			root.dismiss(sheet)
		}
	}
}
