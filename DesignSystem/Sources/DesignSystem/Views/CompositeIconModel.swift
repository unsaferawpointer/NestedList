//
//  CompositeIconModel.swift
//  DesignSystem
//

public struct CompositeIconModel {

	public let icon: IconConfiguration
	public let badge: IconConfiguration?

	// MARK: - Initialization

	public init(icon: IconConfiguration, badge: IconConfiguration?) {
		self.icon = icon
		self.badge = badge
	}
}

// MARK: - Hashable
extension CompositeIconModel: Hashable { }
