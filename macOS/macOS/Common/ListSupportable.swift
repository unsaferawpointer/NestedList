//
//  ListSupportable.swift
//  macOS
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Foundation

protocol ListSupportable {

	func expand(_ ids: [UUID]?)
	func scroll(to id: UUID)
	func select(_ id: UUID)
	func focus(on id: UUID)

	var selection: [UUID] { get }
}
