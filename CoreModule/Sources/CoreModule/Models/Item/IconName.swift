//
//  IconName.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 13.05.2025.
//

import Foundation

public enum IconName: Int {

	case document = 10
	case documents = 11
	case folder = 12
	case package = 13
	case archivebox = 14
	case stack = 15
	case book = 16
	case squareGrid2x2 = 17
	case listStar = 18

	case star = 100
	case heart = 101
}

// MARK: - Codable
extension IconName: Codable { }

// MARK: - Hashable
extension IconName: Hashable { }

// MARK: - CaseIterable
extension IconName: CaseIterable { }
