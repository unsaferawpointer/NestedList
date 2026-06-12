//
//  SettingsView.swift
//  CoreSettings
//
//  Created by Anton Cherkasov on 13.03.2025.
//

import CoreModule
import StoreKit
import SwiftUI

@MainActor
public struct SettingsView {

	@ObservedObject var model: SettingsViewModel

	@Environment(\.openURL) private var openURL

	@Environment(\.requestReview) private var requestReview

	@State private var isEmailErrorPresented = false

	let localization = SettingsLocalization()

	let infoProvider: InfoProvider

	public init(provider: SettingsProvider, infoProvider: InfoProvider = AppInfo()) {
		self.model = SettingsViewModel(provider: provider)
		self.infoProvider = infoProvider
	}
}

// MARK: - View
extension SettingsView: View {

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
			}
			Section(localization.styleSectionTitle) {
				Picker(selection: $model.settings.iconColor) {
					Text(localization.neutralSectionIconColorName)
						.tag(IconColor.neutral)
					Text(localization.accentSectionIconsColorDescription)
						.tag(IconColor.accent)
					Text(localization.primarySectionIconsColorDescription)
						.tag(IconColor.primary)
					Text(localization.multicolorSectionIconsColorDescription)
						.tag(IconColor.multicolor)
				} label: {
					Text(localization.sectionIconsColorTitle)
				}
			}
			Section(localization.supportSectionTitle) {
				Button(action: requestReview.callAsFunction) {
					disclosureRow(
						title: localization.ratingButtonTitle,
						systemImage: "star"
					)
				}
				.buttonStyle(.plain)
				Button(action: openEmail) {
					disclosureRow(
						title: localization.contactDeveloperButtonTitle,
						systemImage: "envelope"
					)
				}
				.buttonStyle(.plain)
				.disabled(infoProvider.supportEmail == nil)
			}
		}
		.formStyle(.grouped)
		#if os(macOS)
		.frame(minWidth: 480, minHeight: 640, maxHeight: .infinity)
		#endif
		.alert(localization.emailErrorTitle, isPresented: $isEmailErrorPresented) {
		} message: {
			Text(localization.emailErrorMessage)
		}
	}
}

// MARK: - Private methods
private extension SettingsView {

	func disclosureRow(title: String, systemImage: String) -> some View {
		HStack {
			Image(systemName: systemImage)
				.frame(width: 22)
				.foregroundStyle(.secondary)
			Text(title)
				.foregroundStyle(.primary)
			Spacer()
			Image(systemName: "chevron.right")
				.font(.footnote.weight(.semibold))
				.foregroundStyle(.tertiary)
		}
		.contentShape(Rectangle())
	}

	func openEmail() {
		guard let email = infoProvider.supportEmail,
			  let url = URL(string: "mailto:\(email)") else {
			isEmailErrorPresented = true
			return
		}
		openURL(url) { accepted in
			if accepted == false {
				isEmailErrorPresented = true
			}
		}
	}
}

#Preview {
	SettingsView(provider: SettingsProvider())
}
