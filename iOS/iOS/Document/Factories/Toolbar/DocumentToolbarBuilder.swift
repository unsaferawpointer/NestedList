//
//  DocumentToolbarBuilder.swift
//  iOS
//
//  Created by Codex on 20.09.2026.
//

import UIKit

@MainActor
protocol DocumentToolbarDelegate: AnyObject {
	func userDidTapToolbar(with id: DocumentToolbarIdentifier)
}

@MainActor
final class DocumentToolbarBuilder {

	private let localization: DocumentLocalizationProtocol = DocumentLocalization()
}

// MARK: - Public interface
extension DocumentToolbarBuilder {

	func build(
		actions: [UIMenuElement],
		delegate: (any DocumentToolbarDelegate)?
	) -> UIBarButtonItem {
		let menu = UIMenu(children: actions + [settingsAction(delegate: delegate)])
		let item = UIBarButtonItem(
			image: UIImage(systemName: "ellipsis"),
			menu: menu
		)
		item.accessibilityIdentifier = DocumentToolbarIdentifier.more.rawValue
		if #available(iOS 26.0, *) {
			item.identifier = DocumentToolbarIdentifier.more.rawValue
		}
		return item
	}
}

// MARK: - Private methods
private extension DocumentToolbarBuilder {

	func settingsAction(delegate: (any DocumentToolbarDelegate)?) -> UIAction {
		UIAction(
			title: localization.settingsItemTitle,
			image: UIImage(systemName: "slider.horizontal.2.square"),
			identifier: .init(DocumentToolbarIdentifier.settings.rawValue)
		) { [weak delegate] _ in
			Task { @MainActor in
				delegate?.userDidTapToolbar(with: .settings)
			}
		}
	}
}
