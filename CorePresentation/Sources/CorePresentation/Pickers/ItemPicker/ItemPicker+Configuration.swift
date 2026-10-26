//
//  ItemPicker+Configuration.swift
//  CorePresentation
//

import Foundation

// MARK: - Nested data structs
extension ItemPicker {

	public struct Configuration {

		public let title: String
		public let subtitle: String?
		public let allowedIDs: Set<UUID>
		public let emptyState: EmptyState

		// MARK: - Initialization

		public init(
			title: String,
			subtitle: String? = nil,
			allowedIDs: Set<UUID>,
			emptyState: EmptyState = .noItems
		) {
			self.title = title
			self.subtitle = subtitle
			self.allowedIDs = allowedIDs
			self.emptyState = emptyState
		}
	}
}
