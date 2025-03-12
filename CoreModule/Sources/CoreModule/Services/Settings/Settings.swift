//
//  Settings.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 10.03.2025.
//

import Foundation

public struct Settings {

	public var completionBehaviour: CompletionBehaviour = .regular

	public var markingBehaviour: MarkingBehaviour = .regular

	// MARK: - Initialization

	public init(
		completionBehaviour: CompletionBehaviour,
		markingBehaviour: MarkingBehaviour
	) {
		self.completionBehaviour = completionBehaviour
		self.markingBehaviour = markingBehaviour
	}
}

// MARK: - Equatable
extension Settings: Equatable { }
