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

	let columns: [GridItem] = [GridItem(.adaptive(minimum: 24), spacing: 8)]

	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: 15) {
				IconButton(
					icon: "circle.slash",
					isSelected: selection == .noIcon
				) {
					selection = .noIcon
				}
				ForEach(IconName.allCases, id: \.self) { icon in
					IconButton(
						icon: IconMapper.map(icon: icon, filled: false)?.systemName ?? "",
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
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.padding(8)
					.background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
					.foregroundColor(isSelected ? .blue : .primary)
					.cornerRadius(8)
			}
		}
		.buttonStyle(PlainButtonStyle())
	}
}
