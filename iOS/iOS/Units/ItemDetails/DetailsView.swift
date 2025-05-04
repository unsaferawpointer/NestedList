//
//  DetailsView.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import SwiftUI
import DesignSystem
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
				buildInfoSection()
				buildProperties()
				buildIconPicker()
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

// MARK: - Helpers
private extension DetailsView {

	@ViewBuilder
	func buildInfoSection() -> some View {
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
	}

	@ViewBuilder
	func buildProperties() -> some View {
		Section(strings.propertiesSectionTitle) {
			Toggle(isOn: $model.properties.isMarked) {
				Text(strings.markToggleTitle)
			}
			.tint(.accentColor)
			.accessibilityIdentifier("toggle-is-marked")
			Toggle(isOn: .init(get: {
				model.properties.style.isSection
			}, set: { newValue in
				model.properties.style = model.properties.style.toggle(isSection: newValue)
			})) {
				Text(strings.sectionToggleTitle)
			}
			.tint(.accentColor)
			.accessibilityIdentifier("toggle-is-section")
		}
	}

	var iconModels: [IconModel] {
		return ItemIcon.allCases.map {
			.customIcon($0)
		}
	}

	@ViewBuilder
	func buildIconPicker() -> some View {
		if model.properties.style.isSection {
			Section("Icon") {
				IconPicker(selection: .init(get: {
					guard case .section(let icon) = model.properties.style else {
						return .noIcon
					}
					guard let icon else {
						return .noIcon
					}
					return .customIcon(icon)
				}, set: { (newValue: IconModel) in
					model.properties.style = .section(icon: newValue.icon)
				}))
			}
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
		var style: ItemStyle = .item
	}
}

#Preview {
	DetailsView(item: .init(
		navigationTitle: "New Item",
		properties: .init(text: ""))) { _, _ in

	}
		.environment(\.locale, .init(identifier: "ru_RU"))
}
