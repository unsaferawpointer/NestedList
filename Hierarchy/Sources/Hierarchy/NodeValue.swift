//
//  NodeValue.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Foundation

public protocol NodeValue: Identifiable, Hashable, Equatable {
	mutating func generateIdentifier()
}
