//
//  Container.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 02.09.2026.
//

public enum Container<Value: MutableIdentifiable> where Value.ID: RandomizableIdentifier {
	case item(value: Value)
	case mirror(id: Value.ID, reference: Value.ID)
}

// MARK: - Equatable
extension Container: Equatable where Value: Equatable { }

// MARK: - Hashable
extension Container: Hashable where Value: Hashable { }

// MARK: - MutableIdentifiable
extension Container: MutableIdentifiable {

	public var id: Value.ID {
		get {
			switch self {
			case let .item(value):		value.id
			case let .mirror(id, _):	id
			}
		}
		set {
			switch self {
			case var .item(value):
				value.id = newValue
				self = .item(value: value)
			case let .mirror(_, reference):
				self = .mirror(id: newValue, reference: reference)
			}
		}
	}
}

// MARK: - Computed Properties
extension Container {

	var itemValue: Value {
		get {
			switch self {
			case let .item(value):
				value
			case .mirror:
				fatalError("Mirror does not own an item value")
			}
		}
		set {
			guard case .item = self else {
				fatalError("Mirror does not own an item value")
			}
			self = .item(value: newValue)
		}
	}

	var reference: Value.ID? {
		switch self {
		case .item:						nil
		case let .mirror(_, reference):	reference
		}
	}
}
