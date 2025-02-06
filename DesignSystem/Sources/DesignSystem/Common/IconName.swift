//
//  IconName.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 27.01.2025.
//

import Foundation

public enum IconName {
	case systemName(_ name: String)
	case named(_ value: String)
}

// MARK: - Hashable
extension IconName: Hashable { }

// MARK: - Computed properties
public extension IconName {

	var systemName: String? {
		switch self {
		case .systemName(let name): return name
		case .named: return nil
		}
	}
}
