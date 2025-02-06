//
//  IconConfiguration.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 19.01.2025.
//

public struct IconConfiguration {

	public var name: IconName
	public var token: ColorToken

	// MARK: - Initialization

	public init(name: IconName, token: ColorToken) {
		self.name = name
		self.token = token
	}
}

// MARK: - Hashable
extension IconConfiguration: Hashable { }
