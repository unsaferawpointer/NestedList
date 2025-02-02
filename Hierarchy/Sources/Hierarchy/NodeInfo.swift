//
//  NodeInfo.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 02.02.2025.
//

import Foundation

public struct NodeInfo<Model: Identifiable> {

	public var model: Model

	public var level: Int
	public var index: Int
	public var parent: Model.ID?
}
