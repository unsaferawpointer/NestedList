//
//  CellDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 20.11.2024.
//

public protocol CellDelegate<Model>: AnyObject {

	associatedtype Model: CellModel

	func cellDidChange(newValue: Model.Value, id: Model.ID)
}
