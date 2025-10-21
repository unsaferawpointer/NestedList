//
//  ColorPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 17.05.2025.
//

import SwiftUI

public struct ColorPicker: View {

	@Binding var selection: ColorToken

	@State var availableColors: [ColorToken] = []

	#if os(iOS)
	let columns: [GridItem] = [GridItem(.adaptive(minimum: 64), spacing: 24)]
	#elseif os(macOS)
	let columns: [GridItem] = [GridItem(.adaptive(minimum: 32), spacing: 8)]
	#endif

	// MARK: - Initialization

	public init(selection: Binding<ColorToken>, availableColors: [ColorToken]) {
		self._selection = selection
		self._availableColors = State(initialValue: availableColors)
	}

	public var body: some View {
		LazyVGrid(columns: columns, spacing: 15) {
			ForEach(availableColors, id: \.self) { color in
				ColorButton(
					color: color,
					isSelected: color == selection
				) {
					selection = color
				}
			}
		}
		.padding()
		.frame(minWidth: 240)
	}
}

#Preview {
	ColorPicker(selection: .constant(.tertiary), availableColors: [.accent, .blue, .cyan])
}
