//
//  SwiftUIView.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 15.06.2025.
//

import SwiftUI

struct IconButton: View {

	let icon: SemanticImage
	let isSelected: Bool
	let action: () -> Void

#if os(iOS)
	var body: some View {
		Button(action: action) {
			VStack {
				icon.image
					.font(.system(size: 24))
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.padding()
					.background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
					.foregroundColor(isSelected ? .accentColor : .primary)
					.cornerRadius(10)
			}
		}
		.buttonStyle(PlainButtonStyle())
	}
	#elseif os(macOS)
	var body: some View {
		Button(action: action) {
			VStack {
				icon.image
					.font(.system(size: 16))
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.padding(8)
					.background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
					.foregroundColor(isSelected ? .accentColor : .primary)
					.cornerRadius(8)
			}
		}
		.buttonStyle(PlainButtonStyle())
	}
	#endif
}

#Preview {
	IconButton(icon: .book, isSelected: false, action: { })
	IconButton(icon: .book, isSelected: true, action: { })
}
