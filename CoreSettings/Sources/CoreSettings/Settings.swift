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

	public var sectionStyle: SectionStyle = .icon

	// MARK: - Initialization

	public init(
		completionBehaviour: CompletionBehavior = .regular,
		markingBehaviour: MarkingBehavior = .regular,
		sectionStyle: SectionStyle = .icon
	) {
		self.completionBehaviour = completionBehaviour
		self.markingBehaviour = markingBehaviour
		self.sectionStyle = sectionStyle
	}
}

// MARK: - Equatable
extension Settings: Equatable { }
