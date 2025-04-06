//
//  MenuFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 06.04.2025.
//

import DesignSystem

final class MenuFactory { }

// MARK: - Public interface
extension MenuFactory {

	static func build(isCompleted: Bool?, isMarked: Bool?, isSection: Bool?) -> [MenuElement] {
		return
		[
			.init(
				id: "",
				content: .menu(
					options: [.inline],
					size: .medium,
					items:
						[
							.init(
								id: ElementIdentifier.cut.rawValue,
								title: "Cut",
								icon: .systemName("scissors"),
								content: .item(state: .off, attributes: [])
							),
							.init(
								id: ElementIdentifier.copy.rawValue,
								title: "Copy",
								icon: .systemName("document.on.document"),
								content: .item(state: .off, attributes: [])
							),
							.init(
								id: ElementIdentifier.paste.rawValue,
								title: "Paste",
								icon: .systemName("document.on.clipboard"),
								content: .item(state: .off, attributes: [])
							)
						]
				)
			),
			.init(
				id: ElementIdentifier.edit.rawValue,
				title: "Edit...",
				icon: .systemName("pencil"),
				content: .item(state: .off, attributes: [])
			),
			.init(
				id: ElementIdentifier.new.rawValue,
				title: "New...",
				icon: .systemName("plus"),
				content: .item(state: .off, attributes: [])
			),
			.init(
				id: "",
				content: .menu(
					options: .inline,
					size: .automatic,
					items:
						[
							.init(
								id: ElementIdentifier.completed.rawValue,
								title: "Completed",
								content: .item(state: isCompleted.state, attributes: [])
							),
							.init(
								id: ElementIdentifier.marked.rawValue,
								title: "Marked",
								content: .item(state: isMarked.state, attributes: [])
							),
							.init(
								id: ElementIdentifier.style.rawValue,
								title: "Section",
								content: .item(state: isSection.state, attributes: [])
							)
						]
				)
			),
			.init(
				id: ElementIdentifier.delete.rawValue,
				title: "Delete",
				icon: .systemName("trash"),
				content: .item(state: .off, attributes: [.destructive])
			)
		]
	}
}

fileprivate extension Optional<Bool> {

	var state: ControlState {
		switch self {
		case .none:					.mixed
		case .some(let wrapped):	wrapped ? .on : .off
		}
	}
}
