//
//  DetailsView.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import SwiftUI

struct DetailsView: View {

	@State var item: ItemModel

	var completionHandler: (ItemModel, Bool) -> Void

	var isValid: Bool {
		return !item.title.isEmpty
	}

	// MARK: - Initialization

	init(item: ItemModel, completionHandler: @escaping (ItemModel, Bool) -> Void) {
		self._item = State(initialValue: item)
		self.completionHandler = completionHandler
	}

	var body: some View {
		NavigationStack {
			Form {
				TextField("", text: $item.title, prompt: Text("Enter text"))
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", role: .cancel) {
						completionHandler(item, false)
					}
				}

				ToolbarItem(placement: .confirmationAction) {
					Button("Save", role: .none) {
						completionHandler(item, true)
					}
					.disabled(!isValid)
				}
			}
		}

	}
}
