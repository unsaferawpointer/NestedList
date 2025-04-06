//
//  ToolbarBuilder.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.04.2025.
//

#if canImport(UIKit)

import UIKit

public final class ToolbarBuilder<ID: Hashable> {

	public init() { }
}

// MARK: - Public interface
public extension ToolbarBuilder {

	static func build(from items: [ToolbarItem], delegate: (any InteractionDelegate<ID>)?) -> [UIBarButtonItem]? {
		guard !items.isEmpty else {
			return nil
		}
		return items.map { item in

			let action = UIAction { [weak delegate] _ in
				delegate?.userDidSelect(item: item.id, with: nil)
			}

			switch item.content {
			case .regular:
				let result = UIBarButtonItem(
					title: item.title,
					image: item.icon?.image,
					primaryAction: action
				)
				result.isEnabled = item.isEnabled
				return result
			case .flexible:
				let result = UIBarButtonItem.flexibleSpace()
				result.isEnabled = item.isEnabled
				return result
			case let .menu(items):
				let result = UIBarButtonItem(
					title: item.title,
					image: item.icon?.image,
					primaryAction: action,
					menu: MenuBuilder.build(from: items, delegate: delegate)
				)
				result.isEnabled = item.isEnabled
				return result
			case let .status(text):
				let label = UILabel()
				label.text = text
				let result = UIBarButtonItem(customView: label)
				result.isEnabled = item.isEnabled
				return result
			}
		}
	}
}
#endif
