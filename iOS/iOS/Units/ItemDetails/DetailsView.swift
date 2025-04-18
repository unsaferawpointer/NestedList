//
//  DetailsView.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import SwiftUI
import CoreModule

struct DetailsView {

	@State var model: Model

	var completionHandler: (Properties, Bool) -> Void

	let strings = DetailsLocalization()

	var isValid: Bool {
		return !model.properties.text.isEmpty
	}

	@FocusState var isFocused: Bool

	// MARK: - Initialization

	init(item: Model, completionHandler: @escaping (Properties, Bool) -> Void) {
		self._model = State(initialValue: item)
		self.completionHandler = completionHandler
	}
}

// MARK: - View
extension DetailsView: View {

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField(
						"",
						text: $model.properties.text,
						prompt: Text(strings.textfieldPlaceholder)
					)
						.font(.body)
						.foregroundStyle(.primary)
						.focused($isFocused)
						.accessibilityIdentifier("textfield-title")
					TextField(strings.notePlaceholder, text: $model.properties.description, axis: .vertical)
						.font(.callout)
						.foregroundStyle(.secondary)
						.accessibilityIdentifier("textfield-description")
				} footer: {
					if !isValid {
						Text(strings.warningText)
							.foregroundStyle(.red)
							.accessibilityIdentifier("label-hint")
					}
				}
				Section(strings.propertiesSectionTitle) {
					Toggle(isOn: $model.properties.isMarked) {
						Text(strings.markToggleTitle)
					}
					.tint(.accentColor)
					.accessibilityIdentifier("toggle-is-marked")
					Toggle(isOn: .init(get: {
						model.properties.style == .section
					}, set: { newValue in
						model.properties.style = newValue ? .section : .item
					})) {
						Text(strings.sectionToggleTitle)
					}
					.tint(.accentColor)
					.accessibilityIdentifier("toggle-is-section")
				}
			}
			.formStyle(.automatic)
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
					.disabled(!isValid)
					.accessibilityIdentifier("button-save")
				}
			}
			.navigationTitle(model.navigationTitle)
			.navigationBarTitleDisplayMode(.inline)
		}
		.onAppear {
			self.isFocused = true
		}

	}
}

// MARK: - Nested data structs
extension DetailsView {

	struct Model {
		var navigationTitle: String
		var properties: Properties
	}

	struct Properties {
		var text: String
		var description: String = ""
		var isMarked: Bool = false
		var style: Item.Style = .item
	}
}

#Preview {
	DetailsView(item: .init(
		navigationTitle: "New Item",
		properties: .init(text: ""))) { _, _ in

	}
		.environment(\.locale, .init(identifier: "ru_RU"))
}
