//
//  SettingsView.swift
//  CoreSettings
//
//  Created by Anton Cherkasov on 13.03.2025.
//

import SwiftUI
import CoreModule

public struct SettingsView: View {

	@ObservedObject var model: SettingsViewModel

	let localization = SettingsLocalization()

	public init(provider: SettingsProvider) {
		self.model = SettingsViewModel(provider: provider)
	}

	public var body: some View {
		Form {
			Section(localization.behaviorsSectionTitle) {
				Toggle(isOn: .init(get: {
					model.settings.completionBehaviour == .moveToEnd
				}, set: { newValue in
					model.settings.completionBehaviour = newValue ? .moveToEnd : .regular
				})) {
					Text(localization.strikethroughBehaviourText)
					Text(localization.strikethroughBehaviourDescription)
				}

				Toggle(isOn: .init(get: {
					model.settings.markingBehaviour == .moveToTop
				}, set: { newValue in
					model.settings.markingBehaviour = newValue ? .moveToTop : .regular
				})) {
					Text(localization.markingBehaviourText)
					Text(localization.markingBehaviourDescription)
				}
			}
		}
		.formStyle(.grouped)
		#if os(macOS)
		.frame(minWidth: 480, minHeight: 640, maxHeight: .infinity)
		#endif
	}
}

#Preview {
	SettingsView(provider: SettingsProvider())
}
