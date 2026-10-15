//
//  NavigationPath.swift
//  macOS
//
//  Created by Anton Cherkasov on 17.10.2026.
//

import Foundation
import CoreModule

struct NavigationPath {

	let root: UUID?
	var suffix: [UUID] = []

	init(root: UUID?) {
		self.root = root
	}

	init(root: UUID?, suffix: [UUID]) {
		self.root = root
		self.suffix = suffix
	}
}

// MARK: - Public Interface
extension NavigationPath {

	var focused: UUID? {
		suffix.last ?? root
	}
}
