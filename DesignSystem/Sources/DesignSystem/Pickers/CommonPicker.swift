//
//  CommonPicker.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 31.03.2026.
//

import SwiftUI

public struct CommonPicker<Value: Hashable, Content: View> {

	let values: [Value]

	@ViewBuilder let emptyContent: () -> Content

	@ViewBuilder let content: (Value) -> Content

	// MARK: - Internal State

	#if os(macOS)
	private let columns: [GridItem] =
	[
		GridItem(.adaptive(minimum: 32), spacing: 8)
	]
	#else
	private let columns: [GridItem] =
	[
		GridItem(.adaptive(minimum: 48), spacing: 8)
	]
	#endif

	// MARK: - Initialization

	public init(
		values: [Value],
		@ViewBuilder emptyContent: @escaping () -> Content,
		@ViewBuilder content: @escaping (Value) -> Content
	) {
		self.values = values
		self.emptyContent = emptyContent
		self.content = content
	}
}

// MARK: - View
extension CommonPicker: View {

	public var body: some View {
		LazyVGrid(columns: columns, spacing: 15) {
			emptyContent()
			ForEach(values, id: \.self) { value in
				content(value)
			}
		}
		.padding()
		.frame(minWidth: 240)
	}
}

#Preview {
	CommonPicker<SemanticImage, _>(values: [.bell, .bookmark, .calendar]) {
		PickerButton(
			icon: .circleSlash,
			foregroundColor: .primary,
			backgroundColor: .gray.opacity(0.1)
		) {

		}
	} content: { value in
		PickerButton(
			icon: value,
			foregroundColor: .primary,
			backgroundColor: .gray.opacity(0.1)
		) {

		}
	}
}
