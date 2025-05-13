//
//  IconName.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 13.05.2025.
//

import Foundation

public enum IconName: Int {

	case document = 0
	case documents = 1
	case folder = 2
	case package = 3
	case archivebox = 4
	case stack = 5
	case book = 6
	case squareGrid2x2 = 7

	case star = 10
	case heart = 11

}

// MARK: - Codable
extension IconName: Codable { }

// MARK: - Hashable
extension IconName: Hashable { }

// MARK: - CaseIterable
extension IconName: CaseIterable { }
