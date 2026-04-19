//
//  ToolbarModel.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 21.09.2025.
//

public struct ToolbarModel {

	public var top: [ToolbarItem] = []
	public var bottom: [ToolbarItem] = []
	public var showUndoGroup: Bool = false

	// MARK: - Initialization

	public init(top: [ToolbarItem], bottom: [ToolbarItem], showUndoGroup: Bool = false) {
		self.top = top
		self.bottom = bottom
		self.showUndoGroup = showUndoGroup
	}
}
