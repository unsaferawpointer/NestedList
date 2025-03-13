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
			Section("Customization") {
				Picker(selection: $model.settings.sectionStyle) {
					Text("None")
						.tag(SectionStyle.noIcon)
					Divider()
					Text("Point")
						.tag(SectionStyle.point)
					Text("Icon")
						.tag(SectionStyle.icon)
				} label: {
					Text("Section Style:")
				}
			}

			Section("Behaviors") {
				Toggle(isOn: .init(get: {
					model.settings.completionBehaviour == .moveToEnd
				}, set: { newValue in
					model.settings.completionBehaviour = newValue ? .moveToEnd : .regular
				})) {
					Text("Move completed items to the end of the list")
					Text("Enable this option to automatically move a completed item to the end of its parent list. This helps maintain order and focus on current tasks by hiding completed ones at the bottom of the list.")
				}

				Toggle(isOn: .init(get: {
					model.settings.markingBehaviour == .moveToTop
				}, set: { newValue in
					model.settings.markingBehaviour = newValue ? .moveToTop : .regular
				})) {
					Text("Move the marked item to the top")
					Text("Enable this option to automatically move the marked item to the top of the list. This helps you quickly focus on the current task without searching for it in the list.")
				}
			}
		}
		.formStyle(.grouped)
		.padding()
		.frame(minWidth: 480, minHeight: 640, maxHeight: .infinity)
	}
}

#Preview {
	SettingsView(provider: SettingsProvider())
}
