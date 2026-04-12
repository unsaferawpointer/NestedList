//
//  PickerButton.swift
//  iOS
//
//  Created by Anton Cherkasov on 29.03.2026.
//

import SwiftUI

public struct PickerButton {

	let icon: SemanticImage

	let showsThemeVariants: Bool

	let foregroundColor: Color

	let backgroundColor: Color

	let action: () -> Void

	// MARK: - Initialization

	public init(
		icon: SemanticImage,
		showsThemeVariants: Bool = false,
		foregroundColor: Color,
		backgroundColor: Color,
		action: @escaping () -> Void
	) {
		self.icon = icon
		self.showsThemeVariants = showsThemeVariants
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
		self.action = action
	}
}

// MARK: - View
extension PickerButton: View {

	public var body: some View {
		Button(action: action) {
			iconView
		}
		.buttonStyle(.plain)
	}
}

// MARK: - Private Methods
private extension PickerButton {

	var iconView: some View {
		GeometryReader { geometry in
			let side = min(geometry.size.width, geometry.size.height)
			iconCellView(side: side)
		}
		.aspectRatio(1.0, contentMode: .fit)
	}

	func iconCellView(side: CGFloat) -> some View {
		let symbolSide = side * 0.5

		return ZStack {
			RoundedRectangle(
				cornerRadius: side * 0.2,
				style: .continuous
			)
				.fill(backgroundColor)

			if showsThemeVariants {
				ZStack {
					icon.image?
						.symbolRenderingMode(.monochrome)
						.font(.system(size: symbolSide))
						.foregroundStyle(foregroundColor)
						.frame(width: symbolSide, height: symbolSide)
						.environment(\.colorScheme, .light)
						.mask(alignment: .leading) {
							Rectangle()
								.frame(width: symbolSide / 2)
						}

					icon.image?
						.symbolRenderingMode(.monochrome)
						.font(.system(size: symbolSide))
						.foregroundStyle(foregroundColor)
						.frame(width: symbolSide, height: symbolSide)
						.environment(\.colorScheme, .dark)
						.mask(alignment: .trailing) {
							Rectangle()
								.frame(width: symbolSide / 2)
						}
				}
			} else {
				icon.image?
					.symbolRenderingMode(.monochrome)
					.font(.system(size: symbolSide))
					.foregroundStyle(foregroundColor)
					.frame(width: symbolSide, height: symbolSide)
			}
		}
	}
}

#Preview {
	VStack {
		PickerButton(
			icon: .calendar,
			foregroundColor: .primary,
			backgroundColor: .gray.opacity(0.1)
		) {

		}
	}
	.frame(width: 256, height: 256)
	.padding(24)
}
