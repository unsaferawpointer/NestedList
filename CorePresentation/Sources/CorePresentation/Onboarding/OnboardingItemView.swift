//
//  OnboardingItemView.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 11.11.2026.
//

import DesignSystem
import SwiftUI

struct OnboardingItemView {

	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	let model: OnboardingItem
}

// MARK: - View
extension OnboardingItemView: View {

	var body: some View {
		HStack(alignment: .firstTextBaseline, spacing: 4) {
			Image(
				systemName: model.state == .expanded
					? "chevron.down"
					: "chevron.forward"
			)
			.font(.caption.weight(.semibold))
			.foregroundStyle(.secondary)
			.opacity(model.state == .leaf ? 0 : 1)
			.frame(width: 12)

			icon(model.icon)
				.font(font(for: model.title.style))
				.fixedSize()
				.symbolEffect(.bounce, value: model.icon.name)
				.symbolEffectsRemoved(reduceMotion)

			VStack(alignment: .leading, spacing: 2) {
				text(model.title)
				if let subtitle = model.subtitle {
					text(subtitle)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)

			if model.showsTrailingDisclosure {
				Image(systemName: "chevron.forward")
					.font(.caption.weight(.semibold))
					.foregroundStyle(.tertiary)
			}
		}
		.padding(.leading, leadingPadding + CGFloat(max(0, model.level)) * 16)
		.padding(.trailing, leadingPadding)
		.padding(.vertical, verticalPadding)
		.background {
			RoundedRectangle(cornerRadius: 8)
				.fill(
					model.isSelected
					? Color.accentColor.opacity(0.15)
					: .clear
				)
		}
		.accessibilityHidden(true)
	}
}

// MARK: - Private methods
private extension OnboardingItemView {

	@ViewBuilder func icon(_ configuration: IconConfiguration) -> some View {
		if let image = (configuration.name ?? .point).image {
			switch configuration.appearence {
			case let .monochrome(token):
				image
					.symbolRenderingMode(.monochrome)
					.foregroundStyle(token.color)
			case let .hierarchical(token):
				image
					.symbolRenderingMode(.hierarchical)
					.foregroundStyle(token.color)
			case let .palette(tokens):
				image
					.symbolRenderingMode(.palette)
					.foregroundStyle(
						(tokens.first ?? .primary).color,
						(tokens.dropFirst().first ?? tokens.first ?? .primary).color,
						(tokens.dropFirst(2).first ?? tokens.first ?? .primary).color
					)
			case .multicolor:
				image.symbolRenderingMode(.multicolor)
			}
		}
	}

	func text(_ model: OnboardingItem.Text) -> some View {
		var content = AttributedString(model.value)
		content.strikethroughStyle = model.strikethrough ? .single : nil
		if model.showsCaret {
			var caret = AttributedString("▏")
			caret.foregroundColor = .secondary
			content.append(caret)
		}

		return Text(content)
			.font(font(for: model.style))
			.foregroundStyle(model.colorToken.color)
			.fixedSize(horizontal: false, vertical: true)
	}

	func font(for style: TextStyle) -> Font {
		switch style {
		case .body:		.body
		case .callout:	.callout
		case .headline:	.headline
		}
	}
}

// MARK: - Private properties
private extension OnboardingItemView {

	var leadingPadding: CGFloat {
		#if os(macOS)
		8
		#else
		4
		#endif
	}

	var verticalPadding: CGFloat {
		#if os(macOS)
		3
		#else
		8
		#endif
	}
}

#Preview("Row") {
	OnboardingItemView(
		model: .init(
			id: .random(),
			title: .init(
				value: "Today",
				style: .headline,
				colorToken: .primary,
				strikethrough: false
			),
			subtitle: nil,
			icon: .init(name: .calendar, token: .red),
			state: .leaf,
			level: 0,
			isSelected: true,
			showsTrailingDisclosure: false
		)
	)
}

#Preview("List") {
	let items = Onboarding.makeItems()
	List {
		ForEach(items) { item in
			OnboardingItemView(model: item)
		}
		.listRowSeparator(.hidden)
		.listRowInsets(
			.init(top: 0, leading: 8, bottom: 0, trailing: 8)
		)
	}
	.listStyle(.plain)
	.environment(\.defaultMinListRowHeight, 0)
}
