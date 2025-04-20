//
//  Settings.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 10.03.2025.
//

import Foundation

public struct Settings {

	public var completionBehaviour: CompletionBehavior = .regular

	public var markingBehaviour: MarkingBehavior = .regular

	public var iconColor: IconColor = .neutral

	// MARK: - Initialization

	public init(
		completionBehaviour: CompletionBehavior = .regular,
		markingBehaviour: MarkingBehavior = .regular,
		iconColor: IconColor = .neutral
	) {
		self.completionBehaviour = completionBehaviour
		self.markingBehaviour = markingBehaviour
		self.iconColor = iconColor
	}
}

// MARK: - Equatable
extension Settings: Equatable { }
