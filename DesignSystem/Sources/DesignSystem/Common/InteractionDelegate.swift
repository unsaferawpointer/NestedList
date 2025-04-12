//
//  InteractionDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.04.2025.
//

#if os(iOS)
public protocol InteractionDelegate<ID>: AnyObject {

	associatedtype ID: Hashable

	func userDidSelect(item: String, with selection: [ID]?)
}
#endif
