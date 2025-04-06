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

	static func build(from elements: [MenuElement], with selection: [ID], delegate: (any InteractionDelegate<ID>)?) -> UIMenu {
		UIMenu(
			children: elements.map {
				buildElement(from: $0, with: selection, delegate: delegate)
			}
		)
	}

	static func build(from elements: [MenuElement], delegate: (any InteractionDelegate<ID>)?) -> UIMenu {
		UIMenu(
			children: elements.map {
				buildElement(from: $0, delegate: delegate)
			}
		)
	}
}

// MARK: - Helpers
private extension MenuBuilder {

	static func buildElement(from model: MenuElement, with selection: [ID], delegate: (any InteractionDelegate<ID>)?) -> UIMenuElement {
		buildElement(from: model) { [weak delegate] in
			delegate?.userDidSelect(item: model.id, with: selection)
		}
	}

	static func buildElement(from model: MenuElement, delegate: (any InteractionDelegate<ID>)?) -> UIMenuElement {
		buildElement(from: model) { [weak delegate] in
			delegate?.userDidSelect(item: model.id, with: nil)
		}
	}

	static func buildElement(from model: MenuElement, action: @escaping () -> Void) -> UIMenuElement {
		return switch model.content {
		case let .menu(options, size, items):
			UIMenu(
				title: model.title,
				identifier: .init(model.id),
				options: options.value,
				preferredElementSize: size.value,
				children: items.map { element in
					buildElement(from: element, action: action)
				}
			)
		case let .item(state, attributes):
			UIAction(
				title: model.title,
				image: model.icon?.image,
				identifier: .init(model.id),
				attributes: attributes.value,
				state: state.value
			) { _ in
				action()
			}
		}
	}
}

#endif
