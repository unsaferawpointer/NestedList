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

	// MARK: - DI by Initialization

	var router: RouterProtocol?

	// MARK: - DI by Property

	var delegate: DocumentViewDelegate?

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
		guard let url = documentURLs.first else {
			return
		}

		let document = Document(fileURL: url)
		let viewController = DocumentViewController(document: document)

		let navigationController = UINavigationController(rootViewController: viewController)
		navigationController.modalPresentationStyle = .fullScreen

		controller.present(navigationController, animated: true)
	}

	func documentBrowser(
		_ controller: UIDocumentBrowserViewController,
		didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void
	) {

		os_log("DocumentBrowserViewController. Creating A New Document.", log: .default, type: .debug)

		let url = FileManager.default.temporaryDirectory.appendingPathComponent("New List.nlist")

		let doc = Document(fileURL: url)

		// Create a new document in a temporary location.
		doc.save(to: url, for: .forCreating) { (saveSuccess) in

			// Make sure the document saved successfully.
			guard saveSuccess else {
				os_log("DocumentBrowserViewController. Unable to create a new document.", log: .default, type: .error)

				// Cancel document creation.
				importHandler(nil, .none)
				return
			}

			// Close the document.
			doc.close(completionHandler: { (closeSuccess) in

				// Make sure the document closed successfully.
				guard closeSuccess else {
					os_log("DocumentBrowserViewController. Unable to create a new document.", log: .default, type: .error)

					// Cancel document creation.
					importHandler(nil, .none)
					return
				}

				// Pass the document's temporary URL to the import handler.
				importHandler(url, .move)
			})
		}
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
