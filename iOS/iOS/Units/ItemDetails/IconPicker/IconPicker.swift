//
//  IconPicker.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.05.2025.
//

import SwiftUI
import CoreModule

struct IconPicker: View {

	let strings = DetailsLocalization()

	@Binding var selection: IconModel

	let columns: [GridItem] = [GridItem(.adaptive(minimum: 64), spacing: 24)]

	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: 15) {
				IconButton(
					icon: "circle.slash",
					isSelected: selection == .noIcon
				) {
					selection = .noIcon
				}
				ForEach(ItemIcon.allCases, id: \.self) { icon in
					IconButton(
						icon: IconMapper.map(icon: icon).systemName ?? "",
						isSelected: icon == selection.icon
					) {
						selection = .customIcon(icon)
					}
				}
			}
			.padding()
		}
	}
}

#Preview {
	IconPicker(selection: .constant(.noIcon))
}

struct IconButton: View {
	let icon: String
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack {
				Image(systemName: icon)
					.font(.system(size: 24))
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.padding()
					.background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
					.foregroundColor(isSelected ? .blue : .primary)
					.cornerRadius(10)
			}
		}
		.buttonStyle(PlainButtonStyle())
	}
}
