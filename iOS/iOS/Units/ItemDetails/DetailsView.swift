//
//  DetailsView.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import SwiftUI
import DesignSystem
import CoreModule
import CorePresentation

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
                buildIconPicker()
                buildColorPicker()
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
					if #available(iOS 26.0, *) {
						Button(strings.saveButtonTitle, role: isValid ? .confirm : .none) {
							completionHandler(model.properties, true)
						}
						.disabled(!isValid)
						.accessibilityIdentifier("button-save")
					} else {
						Button(strings.saveButtonTitle, role: .none) {
							completionHandler(model.properties, true)
						}
						.disabled(!isValid)
						.accessibilityIdentifier("button-save")
					}
				}
			}
			.navigationTitle(model.navigationTitle)
			.navigationBarTitleDisplayMode(.inline)
		}
		.scrollDismissesKeyboard(.immediately)
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
				.onAppear {
					focusedField = .title
				}
		} footer: {
			if !isValid {
				Text(strings.warningText)
					.foregroundStyle(.red)
					.accessibilityIdentifier("label-hint")
			}
		}
		TextField(
			strings.notePlaceholder,
			text: $model.properties.description,
			axis: .vertical
		)
			.focused($focusedField, equals: .note)
			.font(.callout)
			.foregroundStyle(.secondary)
			.submitLabel(.return)
			.accessibilityIdentifier("textfield-description")
	}

	@MainActor
	var availableColors: [ColorToken] {
		ColorsPalette.colors.map {
			ColorMapper.map(color: $0)
		}
	}

	@MainActor
	var availableIcons: [SemanticImage] {
		return IconsPalette.icons
			.map {
				IconMapper.map(icon: $0)
			}
	}

	@MainActor
	@ViewBuilder
	func buildIconPicker() -> some View {
		Section(strings.iconsPickerTitle) {
			IconPicker(icons: availableIcons, selection: .init(get: {
				guard
					let name = model.properties.icon,
					let icon = IconMapper.map(icon: name, filled: false)
				else {
					return nil
				}
				return icon
			}, set: { newValue in
				model.properties.icon = IconMapper.map(icon: newValue)
			}))
		}
	}

	@MainActor
	@ViewBuilder
	func buildColorPicker() -> some View {
		Section(strings.colorPickerTitle) {
			DesignSystem.ColorPicker(selection: .init(get: {
				guard let color = model.properties.tintColor else {
					return nil
				}
				return ColorMapper.map(color: color)
			}, set: { newValue in
				model.properties.tintColor = ColorMapper.map(token: newValue)
			}), availableColors: availableColors)
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
		var focus: DetailsView.Field?
	}

    struct Properties {
        var text: String
        var description: String = ""
        var icon: IconName?
        var tintColor: ItemColor?
    }
}

#Preview {
	DetailsView(item: .init(
		navigationTitle: "New Item",
		properties: .init(text: "")
	)
	) { _, _ in

	}
	.environment(\.locale, .init(identifier: "ru_RU"))
}
