//
//  Resolved.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 09.09.2026.
//

import Foundation

public struct Resolved<Content> {

	public var content: Content

	public var isMirror: Bool

	// MARK: - Initialization

	public init(content: Content, isMirror: Bool = false) {
		self.content = content
		self.isMirror = isMirror
	}
}

// MARK: - Equatable
extension Resolved: Equatable where Content: Equatable { }

// MARK: - Hashable
extension Resolved: Hashable where Content: Hashable { }

// MARK: - Identifiable
extension Resolved: Identifiable where Content: MutableIdentifiable {

	public var id: Content.ID {
		get { content.id }
		set { content.id = newValue }
	}
}

// MARK: - MutableIdentifiable
extension Resolved: MutableIdentifiable where Content: MutableIdentifiable { }
