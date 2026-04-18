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

protocol DocumentViewDelegate: ViewDelegate { }

class DocumentViewController: UIDocumentViewController {

	private var undoRedoItems: [UIBarButtonItem] = []

	// MARK: - DI by Property

	var delegate: DocumentViewDelegate?

	var coordinator: DocumentCoordinator = DocumentCoordinator()

	// MARK: - UIDocumentViewController Life-Cycle

	override func documentDidOpen() {
		super.documentDidOpen()
		configureDocument()
	}

	override func navigationItemDidUpdate() {
		super.navigationItemDidUpdate()
		guard document?.documentState == .normal else {
			navigationItem.setRightBarButtonItems([], animated: false)
			toolbarItems = []
			return
		}
	}

	// MARK: - UIViewController Life-Cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		configureLaunchOptions()
		configureDocument()

		self.undoRedoItems = undoRedoItemGroup.barButtonItems
	}
}

// MARK: - Public Interface
extension DocumentViewController {

	func handleDocument(url: URL) {
		launchOptions
			.browserViewController
			.revealDocument(at: url, importIfNeeded: true) { [weak self] revealedURL, error in
				guard let revealedURL else {
					return
				}
				self?.document = Document(fileURL: revealedURL)
			}
	}
}

// MARK: - Helpers
private extension DocumentViewController {

	func configureLaunchOptions() {
		launchOptions.browserViewController.delegate = self
	}

	func configureDocument() {
		guard let document = document as? Document, !document.documentState.contains(.closed) && isViewLoaded else {
			return
		}
		let content = ContentUnitAssembly.build(router: nil, storage: document.storage)
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
}

// MARK: - ToolbarSupportable
extension DocumentViewController: ToolbarSupportable {

	func displayToolbar(top: [UIBarButtonItem], bottom: [UIBarButtonItem]) {
		navigationItem.setRightBarButtonItems(top, animated: true)
		toolbarItems = undoRedoItems + bottom
	}
}

// MARK: - UIDocumentBrowserViewControllerDelegate
extension DocumentViewController: UIDocumentBrowserViewControllerDelegate {

	func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
		coordinator.documentBrowser(controller, didPickDocumentsAt: documentURLs)
	}

	func documentBrowser(
		_ controller: UIDocumentBrowserViewController,
		didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void
	) {
		coordinator.documentBrowser(controller, didRequestDocumentCreationWithHandler: importHandler)
	}
}

// MARK: - DocumentHandler
extension DocumentViewController: DocumentHandler {

	func handleError(_ error: any Error) {
		Task { @MainActor in
			presentAlert(for: error)
		}
	}
}

// MARK: - Private Methods
private extension DocumentViewController {

	func presentAlert(for error: Error) {

		let nsError = error as NSError

		let title = nsError.localizedDescription
		let reason = nsError.localizedFailureReason
		let suggestion = nsError.localizedRecoverySuggestion

		let alert = UIAlertController(
			title: title,
			message: [reason, suggestion].compactMap(\.self).joined(separator: ". "),
			preferredStyle: .alert
		)

		let action = UIAlertAction(title: "OK", style: .cancel)
		alert.addAction(action)

		present(alert, animated: true)
	}
}
