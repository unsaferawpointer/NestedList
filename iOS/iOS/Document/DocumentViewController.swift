//
//  DocumentViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 14.09.2025.
//

import UIKit
import os.log

import CoreModule

// MARK: - Interfaces

protocol DocumentView: AnyObject { }

protocol DocumentViewDelegate { }

class DocumentViewController: UIDocumentViewController {

	// MARK: - DI by Property

	var delegate: DocumentViewDelegate?

	// MARK: - DI by Initialization

	let localization: AppLocalizable = AppLocalization()

	// MARK: - UIDocumentViewController Life-Cycle

	override func documentDidOpen() {
		configureViewForCurrentDocument()
	}

	// MARK: - UIViewController Life-Cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		configureBrowserViewController()
		configureViewForCurrentDocument()
	}
}

// MARK: - Helpers
private extension DocumentViewController {

	func configureBrowserViewController() {
		if #available(iOS 18.0, *) {
			launchOptions.browserViewController.allowsDocumentCreation = true
			launchOptions.browserViewController.allowsPickingMultipleItems = false
			launchOptions.browserViewController.delegate = self
		}
	}

	func configureViewForCurrentDocument() {
		guard let document = self.document as? Document,
			  !document.documentState.contains(.closed) && isViewLoaded else {
			return
		}
	}
}

// MARK: - DocumentView
extension DocumentViewController: DocumentView { }

// MARK: - UIDocumentBrowserViewControllerDelegate
extension DocumentViewController: UIDocumentBrowserViewControllerDelegate {

	func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
		guard let url = documentURLs.first else {
			return
		}
		presentDocument(at: url, in: controller)
	}

	func documentBrowser(
		_ controller: UIDocumentBrowserViewController,
		didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void
	) {
		os_log("DocumensManager. Creating A New Document.", log: .default, type: .debug)
		createDocument(importHandler: importHandler)
	}
}

// MARK: - Helpers
private extension DocumentViewController {

	func createDocument(importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {

		let fileName = [localization.newFileName, DocumentType.nlist.fileExtension]
			.joined(separator: ".")
		let url = FileManager.default.temporaryDirectory
			.appendingPathComponent(fileName)
		let doc = Document(fileURL: url)

		doc.save(to: url, for: .forCreating) { (saveSuccess) in

			guard saveSuccess else {
				os_log("DocumensManager. Unable to create a new document.", log: .default, type: .error)
				importHandler(nil, .none)
				return
			}

			doc.close(completionHandler: { (closeSuccess) in

				guard closeSuccess else {
					os_log("DocumensManager. Unable to create a new document.", log: .default, type: .error)
					importHandler(nil, .none)
					return
				}

				importHandler(url, .move)
			})
		}
	}

	func presentDocument(at url: URL, in controller: UIDocumentBrowserViewController) {

		let document = Document(fileURL: url)
		let rootViewController = DocumentViewController(document: document)
		let documentViewController = UINavigationController(rootViewController: rootViewController)
		documentViewController.modalPresentationStyle = .fullScreen

		rootViewController.openDocument { isSuccess in
			controller.present(documentViewController, animated: true)
		}

	}
}
