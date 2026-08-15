//
//  MenuSource.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 11.07.2026.
//

/// UI surface that produced a menu action.
public enum MenuSource: String, Equatable, Sendable {

	case main = "main-menu"
	case context = "context-menu"
}
