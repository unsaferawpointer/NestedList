//
//  DetailsView.swift
//  Nested List
//
//  Created by Anton Cherkasov on 15.06.2025.
//

import SwiftUI
import DesignSystem
import CoreModule
import CorePresentation

struct ItemDetailsView {

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
				buildIconPicker()
				buildColorPicker()
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
			.frame(minWidth: 420, idealWidth: 560, maxWidth: 640, minHeight: 480, idealHeight: 640)
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

	var iconModels: [IconModel] {
		return IconName.allCases.map {
			.customIcon(IconMapper.map(icon: $0, filled: false) ?? .textDoc)
		}
	}

	var availableColors: [ColorToken] {
		return ItemColor.allCases.compactMap {
			ColorMapper.map(color: $0)
		}
	}

	@MainActor
	@ViewBuilder
	func buildIconPicker() -> some View {
		Section(strings.iconsPickerTitle) {
			IconPicker(icons: icons, selection: .init(get: {
				guard
					let name = model.properties.icon,
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
					let color = model.properties.tintColor ?? .tertiary
					model.properties.icon = IconMapper.map(icon: iconName)
				}

			}))
		}
	}

	@ViewBuilder
	func buildColorPicker() -> some View {
		Section(strings.colorPickerTitle) {
			DesignSystem.ColorPicker(selection: .init(get: {
				guard let color = model.properties.tintColor else {
					return .tertiary
				}
				return ColorMapper.map(color: color)
			}, set: { newValue in
				model.properties.tintColor = ColorMapper.map(token: newValue)
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
		var icon: IconName?
		var tintColor: ItemColor?
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
