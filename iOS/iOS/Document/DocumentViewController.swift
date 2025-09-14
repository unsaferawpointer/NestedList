//
//  DocumentViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 14.09.2025.
//

import UIKit

// MARK: - Interfaces

protocol DocumentView: AnyObject { }

protocol DocumentViewDelegate { }

class DocumentViewController: UIDocumentViewController {

	// MARK: - DI by Property

	var delegate: DocumentViewDelegate?

	// MARK: - Life-Cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}
}

// MARK: - DocumentView
extension DocumentViewController: DocumentView { }
