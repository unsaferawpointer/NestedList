//
//  ItemIcon.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 02.05.2025.
//

import Foundation

public struct ItemIcon: RawRepresentable {

	public var rawValue: Int

	// MARK: - Initialization

	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
}

// MARK: - Codable
extension ItemIcon: Codable { }

// MARK: - Hashable
extension ItemIcon: Hashable { }
