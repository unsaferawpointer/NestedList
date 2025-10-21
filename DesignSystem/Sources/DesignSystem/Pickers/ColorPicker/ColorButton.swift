//
//  SwiftUIView.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 16.06.2025.
//

import SwiftUI

struct ColorButton: View {

	let color: ColorToken
	let isSelected: Bool
	let action: () -> Void

	#if os(iOS)
	var body: some View {
		Button(action: action) {
			VStack {
				Image(systemName: "circle.fill")
					.foregroundColor(color.color)
					.font(.system(size: 24))
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.padding()
					.background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
					.cornerRadius(10)
			}
		}
		.buttonStyle(PlainButtonStyle())
	}
	#elseif os(macOS)
	var body: some View {
		Button(action: action) {
			VStack {
				Image(systemName: "circle.fill")
					.foregroundColor(color.color)
					.font(.system(size: 16))
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.padding(8)
					.background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
					.cornerRadius(8)
			}
		}
		.buttonStyle(PlainButtonStyle())
	}
	#endif
}

#Preview {
	ColorButton(color: .blue, isSelected: false, action: { })
}
