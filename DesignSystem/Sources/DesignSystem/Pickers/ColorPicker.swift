//
//  ColorPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 17.05.2025.
//

import SwiftUI

public struct ColorPicker: View {

	@Binding var selection: ColorToken?

	@State var colors: [ColorToken] = []

	// MARK: - Initialization

	public init(selection: Binding<ColorToken?>, availableColors: [ColorToken]) {
		self._selection = selection
		self._colors = State(initialValue: availableColors)
	}

	public var body: some View {
			CommonPicker(values: colors) {
				PickerButton(
					icon: .circleSlash,
					foregroundColor: .primary,
					backgroundColor: selection == nil
						? .accentColor.opacity(0.2)
					: .gray.opacity(0.1)
			) {
				selection = nil
			}
			} content: { value in
						PickerButton(
							icon: .filledCircle,
							showsThemeVariants: true,
							foregroundColor: value.color,
						backgroundColor: selection == value
							? .accentColor.opacity(0.2)
					: .gray.opacity(0.1)
			) {
				selection = value
			}
		}
		.frame(minWidth: 240)
	}
}

#Preview {
	ColorPicker(selection: .constant(.tertiary), availableColors: [.accent, .blue, .cyan])
}
