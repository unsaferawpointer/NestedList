//
//  RandomizableIdentifier.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 20.07.2026.
//

import Foundation

public protocol RandomizableIdentifier: Hashable {
	static func random() -> Self
}
