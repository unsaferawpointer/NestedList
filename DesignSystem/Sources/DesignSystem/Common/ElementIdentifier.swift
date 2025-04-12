//
//  ElementIdentifier.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 10.04.2025.
//

public struct ElementIdentifier: RawRepresentable {

	public var rawValue: String

	// MARK: - Initialization

	public init(rawValue: String) {
		self.rawValue = rawValue
	}
}

// MARK: - Hashable
extension ElementIdentifier: Hashable { }
