//
//  ItemIcon.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 02.05.2025.
//

import Foundation

public enum ItemIcon: Int {
	case document = 0
	case documents = 1
	case folder = 2
	case package = 3
	case star = 4

}

// MARK: - Codable
extension ItemIcon: Codable { }

// MARK: - Hashable
extension ItemIcon: Hashable { }

// MARK: - CaseIterable
extension ItemIcon: CaseIterable { }
