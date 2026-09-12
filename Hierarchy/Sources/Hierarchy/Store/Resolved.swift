//
//  Resolved.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 09.09.2026.
//

import Foundation

public struct Resolved<Content, ID: Hashable> {

	public var id: ID

	public var content: Content

	public var isMirror: Bool

	// MARK: - Initialization

	public init(id: ID, content: Content, isMirror: Bool = false) {
		self.id = id
		self.content = content
		self.isMirror = isMirror
	}
}

// MARK: - Equatable
extension Resolved: Equatable where Content: Equatable { }

// MARK: - Hashable
extension Resolved: Hashable where Content: Hashable { }

// MARK: - Identifiable
extension Resolved: Identifiable { }

// MARK: - MutableIdentifiable
extension Resolved: MutableIdentifiable { }
