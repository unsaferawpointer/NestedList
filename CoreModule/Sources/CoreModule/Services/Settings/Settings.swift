//
//  Settings.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 10.03.2025.
//

import Foundation

public struct Settings {

	public var completionBehaviour: CompletionBehaviour = .regular

	// MARK: - Initialization

	public init(completionBehaviour: CompletionBehaviour) {
		self.completionBehaviour = completionBehaviour
	}
}

// MARK: - Equatable
extension Settings: Equatable { }
