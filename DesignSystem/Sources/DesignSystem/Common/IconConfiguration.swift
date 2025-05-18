//
//  IconConfiguration.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 19.01.2025.
//

public struct IconConfiguration {

	public var name: SemanticImage?
	public var appearence: IconAppearence

	// MARK: - Initialization

	public init(name: SemanticImage?, token: ColorToken) {
		self.name = name
		self.appearence = .monochrome(token: token)
	}

	public init(name: SemanticImage?, appearence: IconAppearence) {
		self.name = name
		self.appearence = appearence
	}
}

// MARK: - Hashable
extension IconConfiguration: Hashable { }
