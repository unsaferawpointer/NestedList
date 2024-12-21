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
				TextField("", text: $model.title, prompt: Text("Enter text"))
			}
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

	}
}

// MARK: - Nested data structs
extension DetailsView {

	struct Model {
		var title: String
	}
}
