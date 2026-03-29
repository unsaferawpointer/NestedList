//
//  ErrorMapper.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 28.03.2026.
//

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

import CoreModule

public struct ErrorMapper { }

public extension ErrorMapper {

	static func map(error: DocumentError) -> NSError {
		let userInfo: [String: Any] = [
			NSLocalizedRecoverySuggestionErrorKey: reason(for: error)
		]
		return NSError(
			domain: NSCocoaErrorDomain,
			code: code(for: error),
			userInfo: userInfo
		)
	}
}

// MARK: - Helpers
private extension ErrorMapper {

	static func code(for error: DocumentError) -> Int {
		switch error {
		case .unexpectedFormat:
			return NSFileReadCorruptFileError
		case .unknownVersion:
			return NSFileReadUnknownError
		}
	}

	static func reason(for error: DocumentError) -> String {
		switch error {
		case .unexpectedFormat:
			return String(
				localized: "document-error-unexpected-format-reason",
				table: "Localizable",
				bundle: .module
			)
		case .unknownVersion:
			return String(
				localized: "document-error-unknown-version-reason",
				table: "Localizable",
				bundle: .module
			)
		}
	}
}
