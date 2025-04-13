//
//  SettingsLocalization.swift
//  CoreSettings
//
//  Created by Anton Cherkasov on 13.04.2025.
//

import Foundation

struct SettingsLocalization {
	let behaviorsSectionTitle = String(
		localized: "behaviors-section-title",
		table: "SettingsLocalizable",
		bundle: .module
	)

	let strikethroughBehaviourText = String(
		localized: "strikethrough-behavior-text",
		table: "SettingsLocalizable",
		bundle: .module
	)

	let strikethroughBehaviourDescription = String(
		localized: "strikethrough-behavior-description",
		table: "SettingsLocalizable",
		bundle: .module
	)

	let markingBehaviourText = String(
		localized: "marking-behavior-text",
		table: "SettingsLocalizable",
		bundle: .module
	)

	let markingBehaviourDescription = String(
		localized: "marking-behavior-description",
		table: "SettingsLocalizable",
		bundle: .module
	)
}

//Text("Move completed items to the end of the list")
//Text("Enable this option to automatically move a completed item to the end of its parent list. This helps maintain order and focus on current tasks by hiding completed ones at the bottom of the list.")
//}
//
//Toggle(isOn: .init(get: {
//model.settings.markingBehaviour == .moveToTop
//}, set: { newValue in
//model.settings.markingBehaviour = newValue ? .moveToTop : .regular
//})) {
//Text("Move the marked item to the top")
//Text("Enable this option to automatically move the marked item to the top of the list. This helps you quickly focus on the current task without searching for it in the list.")
