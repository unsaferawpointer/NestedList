//
//  PageView.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 10.05.2026.
//

import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct PageView {
	let systemName: String
	let title: String
	let description: String
}

// MARK: - View
extension PageView: View {

	var body: some View {
		VStack(spacing: 24) {
				GeometryReader { proxy in
					ZStack {
						Color.onboardingTertiarySystemFill
					VStack {
						Spacer()
						buildImage(height: proxy.size.height)
						Spacer()
					}
					.frame(
						maxWidth: .infinity,
						maxHeight: .infinity,
						alignment: .center
					)
				}
				.ignoresSafeArea()
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			VStack {
				Text(title)
					.font(titleFont)
					.fontWeight(.bold)
					.foregroundStyle(.primary)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 32)
				Text(description)
					.font(descriptionFont)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 36)
			}
		}
	}
}

// MARK: - Helpers
#if os(iOS)
private extension PageView {

	func buildImage(height: CGFloat) -> some View {
		if #available(iOS 26.0, *) {
			Image(systemName: systemName)
				.resizable()
				.symbolRenderingMode(.hierarchical)
				.symbolColorRenderingMode(.gradient)
				.aspectRatio(contentMode: .fit)
				.frame(height: height * 0.35)
		} else {
			Image(systemName: systemName)
				.resizable()
				.symbolRenderingMode(.hierarchical)
				.aspectRatio(contentMode: .fit)
				.frame(height: height * 0.35)
		}
	}
}
#elseif os(macOS)
private extension PageView {

	func buildImage(height: CGFloat) -> some View {
		if #available(macOS 26.0, *) {
			Image(systemName: systemName)
				.resizable()
				.symbolRenderingMode(.hierarchical)
				.symbolColorRenderingMode(.gradient)
				.aspectRatio(contentMode: .fit)
				.frame(height: height * 0.5)
		} else {
			Image(systemName: systemName)
				.resizable()
				.symbolRenderingMode(.hierarchical)
				.aspectRatio(contentMode: .fit)
				.frame(height: height * 0.5)
		}
	}
}
#endif

// MARK: - Styling
private extension Color {

	#if os(macOS)
	static let onboardingTertiarySystemFill = Color(nsColor: .tertiarySystemFill)
	#elseif os(iOS)
	static let onboardingTertiarySystemFill = Color(uiColor: .tertiarySystemFill)
	#endif
}

#if os(iOS)
private extension PageView {
	var titleFont: Font {
		.title
	}

	var descriptionFont: Font {
		.title2
	}
}
#elseif os(macOS)
private extension PageView {
	var titleFont: Font {
		.title
	}

	var descriptionFont: Font {
		.title3
	}
}
#endif

#Preview {
	PageView(
		systemName: "slider.horizontal.2.square.on.square",
		title: "Redesigned Icons",
		description: "Customize App Appearance"
	)
}
