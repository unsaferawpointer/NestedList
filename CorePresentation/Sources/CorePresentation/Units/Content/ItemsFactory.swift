//
//  ItemsFactory.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 05.10.2026.
//

import CoreModule
import DesignSystem

public final class ItemsFactory {

	public init() { }
}

// MARK: - Public Interface
public extension ItemsFactory {

	func makeItem(item: Item, isLeaf: Bool, iconColor: IconColor) -> ItemPresentation {
		let isStrikethrough = item.isStrikethrough
		let sourceIcon = IconMapper.map(icon: item.iconName, filled: true)
		let iconName = sourceIcon ?? (item.isMirror ? .linkPoint : .point)
		let token = colorToken(for: item, iconColor: iconColor)
		let appearence = sourceIcon?.preferredAppearance(with: token)
			?? .monochrome(token: token)
		let compositeIcon = CompositeIconModel(
			icon: .init(name: iconName, appearence: appearence),
			badge: item.isMirror && sourceIcon != nil
				? .init(name: .link, appearence: appearence)
				: nil
		)

		return ItemPresentation(
			id: item.id,
			title: .init(
				value: item.text,
				style: isLeaf ? .body : .headline,
				colorToken: isStrikethrough ? .disabledText : .primary,
				strikethrough: isStrikethrough
			),
			subtitle: item.note.map {
				.init(
					value: $0,
					style: .callout,
					colorToken: .secondary,
					strikethrough: false
				)
			},
			compositeIcon: compositeIcon,
			showsTrailingDisclosure: item.isSubitemsHidden,
			isGroup: !isLeaf
		)
	}
}

// MARK: - Private methods
private extension ItemsFactory {

	func colorToken(for item: Item, iconColor: IconColor) -> ColorToken {
		if item.isStrikethrough {
			return .tertiary
		}
		return iconColor.color ?? ColorMapper.map(color: item.tintColor)
	}
}
