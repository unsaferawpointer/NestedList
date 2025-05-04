//
//  IconModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.05.2025.
//

import CoreModule

enum IconModel {

	case noIcon
	case customIcon(ItemIcon)

	var icon: ItemIcon? {
		switch self {
		case .noIcon:
			nil
		case .customIcon(let itemIcon):
			itemIcon
		}
	}
}

// MARK: - Hashable
extension IconModel: Hashable { }

// MARK: - Identifiable
extension IconModel: Identifiable {

	public var id: Self {
		return self
	}
}
