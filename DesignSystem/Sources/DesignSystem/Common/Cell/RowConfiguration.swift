//
//  RowConfiguration.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 29.07.2026.
//

public struct RowConfiguration: Equatable {

	public var level: Int
	public var isExpanded: Bool
	public var isLeaf: Bool

	// MARK: - Initialization

	public init(level: Int, isExpanded: Bool, isLeaf: Bool) {
		self.level = level
		self.isExpanded = isExpanded
		self.isLeaf = isLeaf
	}
}
