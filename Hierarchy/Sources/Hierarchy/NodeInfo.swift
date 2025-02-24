//
//  NodeInfo.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 02.02.2025.
//

import Foundation

public struct NodeInfo<Model: Identifiable> {

	/// Wrapped model
	public var model: Model

	/// Node level
	public var level: Int

	/// Index in parent children array
	public var localIndex: Int

	/// Index in DFT flat list
	public var globalIndex: Int

	/// Parent identifier
	public var parent: Model.ID?
}
