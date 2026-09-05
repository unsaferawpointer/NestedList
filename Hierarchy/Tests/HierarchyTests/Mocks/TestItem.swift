//
//  TestItem.swift
//  HierarchyTests
//
//  Created by Anton Cherkasov on 05.09.2026.
//

@testable import Hierarchy

struct TestItem<ID: Hashable>: Hashable, MutableIdentifiable {
	var id: ID
	var title = ""
}
