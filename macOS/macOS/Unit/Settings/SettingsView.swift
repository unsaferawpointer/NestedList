//
//  SettingsView.swift
//  Nested List
//
//  Created by Anton Cherkasov on 10.03.2025.
//

import SwiftUI
import CoreModule

struct SettingsView: View {

	@ObservedObject var model: SettingsViewModel

	init(provider: SettingsProvider) {
		self.model = SettingsViewModel(provider: provider)
	}

	var body: some View {
		Form {
			Picker(selection: $model.settings.completionBehaviour) {
				Text("None")
					.tag(CompletionBehaviour.regular)
				Divider()
				Text("Move Item to End")
					.tag(CompletionBehaviour.moveToEnd)
			} label: {
				Text("Completion behaviour:")
			}
			Picker(selection: $model.settings.markingBehaviour) {
				Text("None")
					.tag(MarkingBehaviour.regular)
				Divider()
				Text("Move Item to Top")
					.tag(MarkingBehaviour.moveToTop)
			} label: {
				Text("Marking behaviour:")
			}
		}
		.padding()
		.frame(minWidth: 320, maxHeight: .infinity)
	}
}

#Preview {
	SettingsView(provider: SettingsProvider())
}
