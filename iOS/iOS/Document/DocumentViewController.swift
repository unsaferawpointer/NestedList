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

// MARK: - DocumentView
extension DocumentViewController: DocumentView {

	func showDocument(type: Content.ContentView) {
		switch type {
		case .list:
			fatalError()
		case .board:
			fatalError()
		}
	}
}
