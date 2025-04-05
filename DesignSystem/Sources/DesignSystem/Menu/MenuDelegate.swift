//
//  MenuDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 05.04.2025.
//

public protocol MenuDelegate<ID>: AnyObject {

	associatedtype ID: Hashable

	func menuDidSelect<T: RawRepresentable>(item: T, with selection: [ID]) where T.RawValue == String
}
