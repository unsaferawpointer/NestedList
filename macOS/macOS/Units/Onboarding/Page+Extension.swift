//
//  Page+Extension.swift
//  Nested List
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import DesignSystem

extension Page {

	static let newFormat = Page(
		id: "new_format",
		image: "document.badge.plus",
		title: "New File Format",
		description: "We've upgraded your workflow",
		features:
			[
				.init(
					icon: "arrow.down.document",
					title: "Easy Conversion",
					description: "Import legacy TXT files with one click"
				),
				.init(
					icon: "arrow.up.document",
					title: "Full Backward Compatibility",
					description: "Export back to TXT anytime"
				),
				.init(
					icon: "sparkles",
					title: "Exclusive Features",
					description: "Advanced functionality only available in the new format"
				)
			]
	)

	static let customization = Page(
		id: "customization",
		image: "slider.horizontal.2.square.on.square",
		title: "Redesigned Icons",
		description: "Customize App Appearance",
		features:
			[
				.init(
					icon: "arrow.down.document",
					title: "Unique Icons for Each Section",
					description: "Assign distinct icons to different categories"
				),
				.init(
					icon: "arrow.up.document",
					title: "Multiple Display Styles",
					description: "Choose the visual style that suits you best"
				),
				.init(
					icon: "sparkles",
					title: "Seamless Theme Adaptation",
					description: "Icons automatically adjust to light/dark mode"
				)
			]
	)
}
