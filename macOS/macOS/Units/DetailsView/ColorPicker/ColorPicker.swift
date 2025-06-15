//
//  ColorPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 17.05.2025.
//

import SwiftUI
import DesignSystem
import CoreModule

struct ColorPicker: View {

	let strings = DetailsLocalization()

	@Binding var selection: ItemColor

	let columns: [GridItem] = [GridItem(.adaptive(minimum: 24), spacing: 12)]

	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: 15) {
				ForEach(ItemColor.allCases, id: \.self) { color in
					ColorButton(
						color: ColorMapper.map(color: color),
						isSelected: color == selection
					) {
						selection = color
					}
				}
			}
			.padding()
		}
	}
}

#Preview {
	ColorPicker(selection: .constant(.tertiary))
}

struct ColorButton: View {
	let color: ColorToken
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack {
				Image(systemName: "circle.fill")
					.foregroundColor(color.color)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.padding(8)
					.background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
					.cornerRadius(8)
			}
		}
		.buttonStyle(PlainButtonStyle())
	}
}
