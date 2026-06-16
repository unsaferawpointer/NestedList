//
//  ItemDetailsView.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 26.04.2026.
//

import SwiftUI
import DesignSystem
import CoreModule

@MainActor
public struct ItemDetailsView {

	@State var model: Model

	var completionHandler: (Properties, Bool) -> Void

	let strings = DetailsLocalization()

	var isValid: Bool {
		return !model.properties.text.isEmpty
	}

	@MainActor
	let icons = IconsPalette.chunked()
		.flatMap{ $0 }
		.map { IconMapper.map(icon: $0) }

	@FocusState private var focusedField: Field?

	// MARK: - Initialization

	public init(item: Model, completionHandler: @escaping (Properties, Bool) -> Void) {
		self._model = State(initialValue: item)
		self.completionHandler = completionHandler
	}
}

// MARK: - View
extension ItemDetailsView: View {

	public var body: some View {
		NavigationStack {
			Form {
				buildInfoSection()
			}
			.formStyle(.grouped)
			.scrollIndicators(.hidden)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button(strings.cancelButtonTitle, role: .cancel) {
						completionHandler(model.properties, false)
					}
					.accessibilityIdentifier("button-cancel")
				}

				ToolbarItem(placement: .confirmationAction) {
					Button(strings.saveButtonTitle, role: .none) {
						completionHandler(model.properties, true)
					}
					.keyboardShortcut(.return)
					.disabled(!isValid)
					.accessibilityIdentifier("button-save")
				}
			}
			.frame(minWidth: 420, idealWidth: 560, maxWidth: 640, minHeight: 180, idealHeight: 240)
			.navigationTitle(model.navigationTitle)
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
		}
	}
}

// MARK: - Helpers
private extension ItemDetailsView {

	@ViewBuilder
	func buildInfoSection() -> some View {
		Section {
			TextField(
				"Text",
				text: $model.properties.text,
				prompt: Text(strings.textfieldPlaceholder)
			)
				.focused($focusedField, equals: .title)
				.font(.body)
				.foregroundStyle(.primary)
				.submitLabel(.continue)
				.onSubmit {
					focusedField = .note
				}
				.accessibilityIdentifier("textfield-title")
			TextField(
				strings.notePlaceholder,
				text: $model.properties.description,
				axis: .vertical
			)
				.focused($focusedField, equals: .note)
				.font(.callout)
				.foregroundStyle(.primary)
				.submitLabel(.return)
				.accessibilityIdentifier("textfield-description")
		} footer: {
			if !isValid {
				Text(strings.warningText)
					.foregroundStyle(.red)
					.accessibilityIdentifier("label-hint")
			}
		}
		.onSubmit {
			switch focusedField {
			case .title:
				focusedField = .note
			default:
				focusedField = nil
			}
		}
	}
}

// MARK: - Nested data structs
extension ItemDetailsView {

	public enum Field: Hashable {
		case title
		case note
	}

	public struct Model {
		public var navigationTitle: String
		public var properties: Properties
		public var focus: ItemDetailsView.Field?

		public init(
			navigationTitle: String,
			properties: Properties,
			focus: ItemDetailsView.Field? = nil
		) {
			self.navigationTitle = navigationTitle
			self.properties = properties
			self.focus = focus
		}
	}

	public struct Properties {
		public var text: String
		public var description: String = ""

		public init(text: String, description: String = "") {
			self.text = text
			self.description = description
		}
	}
}

#Preview {
	ItemDetailsView(item: .init(
		navigationTitle: "New Item",
		properties: .init(text: "")
	)
	) { _, _ in

	}
	.environment(\.locale, .init(identifier: "ru_RU"))
}
