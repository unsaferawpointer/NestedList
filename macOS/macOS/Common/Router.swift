//
//  Router.swift
//  Nested List
//
//  Created by Anton Cherkasov on 12.09.2025.
//

import AppKit
import SwiftUI

final class Router {

	unowned var root: NSViewController

	// MARK: - Initialization

	init(root: NSViewController) {
		self.root = root
	}
}

extension Router {

	func showDetails(with model: DetailsView.Model, completionHandler: @escaping (DetailsView.Properties, Bool) -> Void) {

		let contentViewController = NSHostingController(
			rootView:
				DetailsView(item: model, completionHandler: completionHandler)
		)
		contentViewController.title = model.navigationTitle
		root.presentAsSheet(contentViewController)
	}
}
