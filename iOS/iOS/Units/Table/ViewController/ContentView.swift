//
//  ContentView.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.02.2025.
//

import Foundation
import Hierarchy
import DesignSystem

protocol ContentView: AnyObject {

	func display(_ snapshot: Snapshot<ItemModel>)
	func display(_ toolbar: ToolbarModel)
	func setEditing(_ editingMode: EditingMode?)

	func scroll(to id: UUID)
	func expand(_ id: UUID)
	func expandAll()
	func collapseAll()
	func selectAll()

	var selection: [UUID] { get }
}
