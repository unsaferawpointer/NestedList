//
//  ItemPicker+EmptyState.swift
//  CorePresentation
//

import Foundation

// MARK: - Nested data structs
extension ItemPicker {

	/// Text displayed when there are no items available for selection.
	public struct EmptyState {

		public let title: String
		public let message: String?

		// MARK: - Initialization

		/// Pass localized strings appropriate to the picker's context.
		public init(title: String, message: String? = nil) {
			self.title = title
			self.message = message
		}

		/// The default empty state, localized by CorePresentation.
		public static var noItems: Self {
			Self(
				title: String(localized: "item-picker-empty-title", bundle: .module),
				message: String(localized: "item-picker-empty-message", bundle: .module)
			)
		}
	}
}
