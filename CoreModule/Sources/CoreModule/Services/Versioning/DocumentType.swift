//
//  DocumentType.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

public enum DocumentType: String {
	case text = "public.plain-text"
	case nlist = "dev.zeroindex.nested-list.doc"
}

// MARK: - Computed properties
public extension DocumentType {

	var lastVersion: Version {
		switch self {
		case .nlist:
			return .init(major: 1)
		default:
			fatalError("Can`t support other types")
		}
	}

	var fileExtension: String {
		switch self {
		case .text: 	"txt"
		case .nlist: 	"nlist"
		}
	}
}
