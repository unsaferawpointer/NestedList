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
		let iconName = IconMapper.map(icon: item.iconName, filled: true)
		let isLinkPoint = iconName == nil && item.isMirror
		let iconAppearence = iconAppearence(
			for: item,
			iconName: iconName,
			iconColor: iconColor,
			isLinkPoint: isLinkPoint
		)
		let compositeIcon = makeCompositeIcon(
			iconName: iconName,
			isLinkPoint: isLinkPoint,
			isMirror: item.isMirror,
			appearence: iconAppearence
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

	func makeCompositeIcon(
		iconName: SemanticImage?,
		isLinkPoint: Bool,
		isMirror: Bool,
		appearence: IconAppearence
	) -> CompositeIconModel? {
		guard let name = iconName ?? (isLinkPoint ? .linkPoint : nil) else {
			return nil
		}

		return CompositeIconModel(
			icon: .init(name: name, appearence: appearence),
			badge: isMirror && iconName != nil ? .init(name: .link, appearence: appearence) : nil
		)
	}

	func iconAppearence(
		for item: Item,
		iconName: SemanticImage?,
		iconColor: IconColor,
		isLinkPoint: Bool
	) -> IconAppearence {
		let token = colorToken(for: item, iconColor: iconColor)
		if isLinkPoint {
			return .monochrome(token: token)
		}
		return iconName?.preferredAppearance(with: token) ?? .monochrome(token: token)
	}

	func colorToken(for item: Item, iconColor: IconColor) -> ColorToken {
		if item.isStrikethrough {
			return .tertiary
		}
		return iconColor.color ?? ColorMapper.map(color: item.tintColor)
	}
}
