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
		} footer: {
			if !isValid {
				Text(strings.warningText)
					.foregroundStyle(.red)
					.accessibilityIdentifier("label-hint")
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
