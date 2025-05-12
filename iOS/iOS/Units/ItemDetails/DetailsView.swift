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

	@FocusState private var focusedField: Field?

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
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				focusedField = .title
			}

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
				.foregroundStyle(.secondary)
				.accessibilityIdentifier("textfield-description")
		} footer: {
			if !isValid {
				Text(strings.warningText)
					.foregroundStyle(.red)
					.accessibilityIdentifier("label-hint")
			}
		}
		.scrollDismissesKeyboard(.interactively)
		.ignoresSafeArea(.keyboard)
		.onSubmit {
			switch focusedField {
			case .title:
				focusedField = .note
			default:
				focusedField = nil
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

	enum Field: Hashable {
		case title
		case note
	}

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
