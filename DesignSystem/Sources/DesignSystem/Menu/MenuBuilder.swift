//
//  MenuBuilder.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.04.2025.
//

public final class MenuBuilder<ID: Hashable> { }

#if canImport(UIKit)

import UIKit

// MARK: - Public interface
public extension MenuBuilder {

	static func build(from elements: [MenuElement], with selection: [ID]?, delegate: (any InteractionDelegate<ID>)?) -> UIMenu {
		UIMenu(
			children: elements.map {
				buildElement(from: $0, with: selection, delegate: delegate)
			}
		)
	}
}

// MARK: - Helpers
private extension MenuBuilder {

	static func buildElement(from model: MenuElement, with selection: [ID]?, delegate: (any InteractionDelegate<ID>)?) -> UIMenuElement {
		return switch model.content {
		case let .menu(options, size, items):
			UIMenu(
				title: model.title,
				identifier: .init(model.id),
				options: options.value,
				preferredElementSize: size.value,
				children: items.map { element in
					buildElement(from: element, with: selection, delegate: delegate)
				}
			)
		case let .item(state, attributes):
			UIAction(
				title: model.title,
				image: UIImage(systemName: model.icon ?? ""),
				identifier: .init(model.id),
				attributes: attributes.value,
				state: state.value
			) { _ in
				delegate?.userDidSelect(item: model.id, with: selection)
			}
		}
	}
}

#endif
