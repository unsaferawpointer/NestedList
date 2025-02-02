//
//  SnapshotCache.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 02.02.2025.
//

import Foundation

struct SnapshotCache<ID: Hashable> {

	var identifiers: Set<ID> = .init()
	var flattened: [ID] = []
	var maxLevel: Int = 0
}
