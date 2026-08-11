//
//  MutableIdentifiable.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 20.07.2026.
//

public protocol MutableIdentifiable: Identifiable {
	var id: ID { get set }
}
