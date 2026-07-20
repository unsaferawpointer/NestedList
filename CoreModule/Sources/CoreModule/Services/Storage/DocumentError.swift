//
//  DocumentError.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

public enum DocumentError: Error, Sendable {
	case unexpectedFormat
	case unknownVersion
}
