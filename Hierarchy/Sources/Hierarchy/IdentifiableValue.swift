//
//  IdentifiableValue.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 01.06.2025.
//

import Foundation

public protocol IdentifiableValue: Identifiable, Hashable {
	mutating func generateId()
}
