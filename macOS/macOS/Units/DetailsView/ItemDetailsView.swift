//
//  DetailsView.swift
//  Nested List
//
//  Created by Anton Cherkasov on 15.06.2025.
//

import SwiftUI
import DesignSystem
import CoreModule

struct ItemDetailsView {

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
extension ItemDetailsView: View {

	var body: some View {
		NavigationStack {
			Form {
				buildInfoSection()
				buildProperties()
				if model.properties.isSection {
					buildIconPicker()
				}

				if model.properties.icon != nil && model.properties.isSection {
					buildColorPicker()
				}
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
			.frame(minWidth: 360, idealWidth: 420, maxWidth: 640, minHeight: 480, idealHeight: 640)
			.navigationTitle(model.navigationTitle)
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

	@ViewBuilder
	func buildProperties() -> some View {
		Section(strings.propertiesSectionTitle) {
			Toggle(isOn: $model.properties.isStrikethrough) {
				Text(strings.strikeThroughToggleTitle)
			}
			.tint(.accentColor)
			.accessibilityIdentifier("toggle-strikethrough")
			Toggle(isOn: $model.properties.isMarked) {
				Text(strings.markToggleTitle)
			}
			.tint(.accentColor)
			.accessibilityIdentifier("toggle-is-marked")
			Toggle(isOn: $model.properties.isSection) {
				Text(strings.sectionToggleTitle)
			}
			.tint(.accentColor)
			.accessibilityIdentifier("toggle-is-section")
		}
	}

	var iconModels: [IconModel] {
		return IconName.allCases.map {
			.customIcon(IconMapper.map(icon: $0, filled: false) ?? .textDoc(filled: false))
		}
	}

	var availableColors: [ColorToken] {
		return ItemColor.allCases.compactMap {
			ColorMapper.map(color: $0)
		}
	}

	@ViewBuilder
	func buildIconPicker() -> some View {
		Section(strings.iconsPickerTitle) {
			IconPicker(selection: .init(get: {
				guard model.properties.isSection else {
					return .noIcon
				}

				guard
					let name = model.properties.icon?.name,
					let icon = IconMapper.map(icon: name, filled: false)
				else {
					return .noIcon
				}
				return .customIcon(icon)
			}, set: { newValue in
				switch newValue {
				case .noIcon:
					model.properties.icon = nil
				case .customIcon(let iconName):
					let color = model.properties.icon?.color ?? .tertiary
					model.properties.icon = ItemIcon(name: IconMapper.map(icon: iconName), color: color)
				}

			}))
		}
	}

	@ViewBuilder
	func buildColorPicker() -> some View {
		Section(strings.colorPickerTitle) {
			DesignSystem.ColorPicker(selection: .init(get: {
				guard model.properties.isSection else {
					return .tertiary
				}
				guard let color = model.properties.icon?.color else {
					return .tertiary
				}
				return ColorMapper.map(color: color)
			}, set: { newValue in
				guard let icon = model.properties.icon else {
					return
				}
				model.properties.icon? = ItemIcon(
					name: icon.name,
					color: ColorMapper.map(token: newValue) ?? .quaternary
				)
			}),
				availableColors: availableColors
			)
		}
	}
}

// MARK: - Nested data structs
extension ItemDetailsView {

	enum Field: Hashable {
		case title
		case note
	}

	struct Model {
		var navigationTitle: String
		var properties: Properties
		var focus: ItemDetailsView.Field?
	}

	struct Properties {
		var text: String
		var description: String = ""
		var isStrikethrough: Bool = false
		var isMarked: Bool = false
		var isSection: Bool = false
		var icon: ItemIcon?
	}
}

#Preview {
	ItemDetailsView(item: .init(
		navigationTitle: "New Item",
		properties: .init(text: "", isSection: false)
	)
	) { _, _ in

	}
	.environment(\.locale, .init(identifier: "ru_RU"))
}
