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
					TextField("", text: $model.properties.text, prompt: Text("Enter text"))
						.font(.body)
						.foregroundStyle(.primary)
						.focused($isFocused)
						.accessibilityIdentifier("textfield-title")
					TextField("Note to Item...", text: $model.properties.description, axis: .vertical)
						.font(.callout)
						.foregroundStyle(.secondary)
						.accessibilityIdentifier("textfield-description")
				} footer: {
					if !isValid {
						Text("Text is empty")
							.foregroundStyle(.red)
							.accessibilityIdentifier("label-hint")
					}
				}
				Section("Properties") {
					Toggle(isOn: $model.properties.isMarked) {
						Text("Marked")
					}
					.tint(.accentColor)
					.accessibilityIdentifier("toggle-is-marked")
					Picker(selection: $model.properties.style) {
						Text("Item")
							.tag(Item.Style.item)
						Text("Section")
							.tag(Item.Style.section)
					} label: {
						Text("Style")
					}
				}
			}
			.formStyle(.automatic)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", role: .cancel) {
						completionHandler(model.properties, false)
					}
					.accessibilityIdentifier("button-cancel")
				}

				ToolbarItem(placement: .confirmationAction) {
					Button("Save", role: .none) {
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
}
