//
//  UnitView.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.02.2025.
//

import Foundation
import Hierarchy

protocol UnitView: AnyObject {

	func display(_ snapshot: Snapshot<ItemModel>)

	func showDetails(with model: DetailsView.Model, completionHandler: @escaping (DetailsView.Properties, Bool) -> Void)
	func hideDetails()

	func expand(_ id: UUID)
	func expandAll()
}
