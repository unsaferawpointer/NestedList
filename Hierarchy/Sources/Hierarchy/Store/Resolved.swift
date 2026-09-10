//
//  Resolved.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 09.09.2026.
//

import Foundation

public struct Resolved<Content: Identifiable> {

	public var id: Content.ID

	public var content: Content

	public var isMirror: Bool

	// MARK: - Initialization

	public init(id: Content.ID, content: Content, isMirror: Bool = false) {
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
