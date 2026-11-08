//
//  NavigationPath.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 17.10.2026.
//

import Foundation

public struct NavigationPath {

	public let root: UUID?
	public var suffix: [UUID] = []

	public init(root: UUID?) {
		self.root = root
	}

	public init(root: UUID?, suffix: [UUID]) {
		self.root = root
		self.suffix = suffix
	}
}

// MARK: - Public Interface
public extension NavigationPath {

	var focused: UUID? {
		suffix.last ?? root
	}
}
