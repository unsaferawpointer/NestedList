//
//  Container.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 02.09.2026.
//

public enum Container<Content, ID: RandomizableIdentifier> {
	case item(id: ID, content: Content)
	case mirror(id: ID, reference: ID)
}

// MARK: - Equatable
extension Container: Equatable where Content: Equatable { }

// MARK: - Hashable
extension Container: Hashable where Content: Hashable { }

// MARK: - MutableIdentifiable
extension Container: MutableIdentifiable {

	public var id: ID {
		get {
			switch self {
			case let .item(id, _):		id
			case let .mirror(id, _):	id
			}
		}
		set {
			switch self {
			case let .item(_, content):
				self = .item(id: newValue, content: content)
			case let .mirror(_, reference):
				self = .mirror(id: newValue, reference: reference)
			}
		}
	}
}

// MARK: - Computed Properties
extension Container {

	var itemContent: Content {
		get {
			switch self {
			case let .item(_, content):
				content
			case .mirror:
				fatalError("Mirror does not own item content")
			}
		}
		set {
			guard case let .item(id, _) = self else {
				fatalError("Mirror does not own item content")
			}
			self = .item(id: id, content: newValue)
		}
	}

	/// The identifier of the represented item.
	///
	/// For an item, this is its own identifier. For a mirror, this is the referenced item's identifier.
	var itemID: ID {
		switch self {
		case let .item(id, _):			id
		case let .mirror(_, reference):	reference
		}
	}

	var reference: ID? {
		switch self {
		case .item:						nil
		case let .mirror(_, reference):	reference
		}
	}
}
