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

	func showDetails(with model: ItemDetailsView.Model, completionHandler: @escaping (ItemDetailsView.Properties, Bool) -> Void) {

		let contentViewController = NSHostingController(
			rootView:
				ItemDetailsView(item: model, completionHandler: completionHandler)
		)
		contentViewController.title = model.navigationTitle
		root.presentAsSheet(contentViewController)
	}
}
