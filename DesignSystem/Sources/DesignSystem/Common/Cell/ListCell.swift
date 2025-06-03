//
//  ListCell.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 16.11.2024.
//

#if canImport(Cocoa)
import Cocoa
#endif

#if os(macOS)
public protocol ListCell: NSView {

	associatedtype Model: CellModel

	static var reuseIdentifier: String { get }

	var model: Model { get set }

	init(_ model: Model)

	var delegate: (any CellDelegate<Model>)? { get set }

	func focus(on field: String)
}
#endif

#if os(iOS)
import UIKit

public protocol ListCell: UITableViewCell {

	associatedtype Model: CellModel

	static var reuseIdentifier: String { get }

	func validateIndent()
}
#endif
