//
//  IconModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.05.2025.
//

public enum IconModel {

	case noIcon
	case customIcon(SemanticImage)

	var icon: SemanticImage? {
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
