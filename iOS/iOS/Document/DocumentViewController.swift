//
//  DocumentViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 14.09.2025.
//

import UIKit
import os.log

import CoreModule
import DesignSystem

// MARK: - Interfaces

protocol DocumentView: AnyObject {
	func showDocument(type: Content.ContentView)
}

protocol DocumentViewDelegate: ViewDelegate { }

class DocumentViewController: UIDocumentViewController {

	weak var content: UIViewController?

	private var undoRedoItems: [UIBarButtonItem] = []

	// MARK: - DI by Initialization

	var router: RouterProtocol?

	// MARK: - DI by Property

	var delegate: DocumentViewDelegate?

	// MARK: - UIDocumentViewController Life-Cycle

	override func documentDidOpen() {
		configureViewForCurrentDocument()
	}

	// MARK: - UIViewController Life-Cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		configureViewForCurrentDocument()

		self.undoRedoItems = undoRedoItemGroup.barButtonItems
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		document?.close { (success) in
			guard success else {
				assertionFailure( "*** Error closing document ***")
				return
			}
			os_log("==> Document saved and closed", log: .default, type: .debug)
		}
	}
}

// MARK: - Helpers
private extension DocumentViewController {

	func configureViewForCurrentDocument() {
		guard let document = self.document as? Document,
			  !document.documentState.contains(.closed) && isViewLoaded else {
			return
		}
		delegate = DocumentAssembly.build(self, storage: document.storage)
		delegate?.viewDidChange(state: .didLoad)
	}
}

// MARK: - ToolbarSupportable
extension DocumentViewController: ToolbarSupportable {

	func displayToolbar(top: [UIBarButtonItem], bottom: [UIBarButtonItem]) {
		navigationItem.setRightBarButtonItems(top, animated: true)
		toolbarItems = undoRedoItems + bottom
	}
}

// MARK: - DocumentView
extension DocumentViewController: DocumentView {

	func showDocument(type: Content.ContentView) {

		if !Thread.isMainThread {
			os_log("DocumentViewController. ShowDocument: Is not main Thread", log: .default, type: .error)
		}

		guard let document = self.document as? Document, let router else {
			return
		}

		if content is TableViewController {
			return
		} else if let content {
			remove(content)

			let viewController = ContentUnitAssembly.build(router: router, storage: document.storage)
			addContent(viewController)
			self.content = viewController
		} else {
			let viewController = ContentUnitAssembly.build(router: router, storage: document.storage)
			addContent(viewController)
			self.content = viewController
		}
	}
}

// MARK: - Helpers
private extension DocumentViewController {

	func addContent(_ content: UIViewController) {

		addChild(content)
		view.addSubview(content.view)
		content.view.translatesAutoresizingMaskIntoConstraints = false
		content.didMove(toParent: self)

		NSLayoutConstraint.activate(
			[
				content.view.topAnchor.constraint(equalTo: view.topAnchor),
				content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				content.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				content.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
			]
		)
	}

	func remove(_ content: UIViewController) {
		content.willMove(toParent: nil)
		content.view.removeFromSuperview()
		content.removeFromParent()
	}
}
