//
//  UnitViewDelegate.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.02.2025.
//

import Foundation
import CoreModule
import DesignSystem

protocol UnitViewDelegate<ID>: DropDelegate, ViewDelegate {

	associatedtype ID

	func userTappedCreateButton()
	func userTappedEditButton(id: ID)
	func userTappedDeleteButton(ids: [ID])
	func userTappedAddButton(target: ID)
	func userSetStatus(isDone: Bool, id: ID)
	func userMark(isMarked: Bool, id: ID)
	func userSetStyle(style: Item.Style, id: ID)
	func userTappedCutButton(ids: [ID])
	func userTappedPasteButton(target: ID)
	func userTappedCopyButton(ids: [ID])
}
