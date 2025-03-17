//
//  ListDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 16.02.2025.
//

import Foundation

#if os(macOS)
public protocol ListDelegate<ID>: AnyObject {

	associatedtype ID

	func handleDoubleClick(on item: ID)
}
#endif

#if os(iOS)
public protocol ListDelegate<ID>: AnyObject {

	associatedtype ID

	func listItemHasBeenDelete (id: ID)

	func listDidChangeSelection(ids: [ID])
}
#endif
