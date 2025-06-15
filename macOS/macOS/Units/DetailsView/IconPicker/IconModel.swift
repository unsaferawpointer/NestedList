//
//  IconModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.05.2025.
//

import CoreModule

enum IconModel {

	case noIcon
	case customIcon(IconName)

	var icon: IconName? {
		switch self {
		case .noIcon:
			nil
		case .customIcon(let name):
			name
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
