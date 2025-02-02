//
//  DetailsView.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import SwiftUI

struct DetailsView {

	@State var model: Model

	var completionHandler: (Model, Bool) -> Void

	var isValid: Bool {
		return !model.title.isEmpty
	}

	@FocusState var isFocused: Bool

	// MARK: - Initialization

	init(item: Model, completionHandler: @escaping (Model, Bool) -> Void) {
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
					TextField("", text: $model.title, prompt: Text("Enter text"))
						.focused($isFocused)
					TextField("Note to Item...", text: $model.description, axis: .vertical)
				} footer: {
					if !isValid {
						Text("Text is empty")
							.foregroundStyle(.red)
					}
				}
				Section {
					Toggle(isOn: $model.isMarked) {
						Text("Is marked")
					}
					.tint(.accentColor)
				}

			}
			.formStyle(.automatic)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", role: .cancel) {
						completionHandler(model, false)
					}
				}

				ToolbarItem(placement: .confirmationAction) {
					Button("Save", role: .none) {
						completionHandler(model, true)
					}
					.disabled(!isValid)
				}
			}
		}
		.onAppear {
			self.isFocused = true
		}

	}
}

// MARK: - Nested data structs
extension DetailsView {

	struct Model {
		var title: String
		var description: String = ""
		var isMarked: Bool = false
	}
}

#Preview {
	DetailsView(item: .init(title: "New Item", description: "")) { _, _ in

	}
}
