//
//  ToolbarModel.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 21.09.2025.
//

public struct ToolbarModel {

	public var top: [ToolbarItem] = []
	public var bottom: [ToolbarItem] = []

	// MARK: - Initialization

	public init(top: [ToolbarItem], bottom: [ToolbarItem]) {
		self.top = top
		self.bottom = bottom
	}
}
