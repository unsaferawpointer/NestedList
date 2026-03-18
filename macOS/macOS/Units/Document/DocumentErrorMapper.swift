//
//  DocumentErrorMapper.swift
//  Nested List
//
//  Created by Anton Cherkasov on 18.03.2026.
//

import AppKit
import CoreModule

struct DocumentErrorMapper { }

extension DocumentErrorMapper {

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
private extension DocumentErrorMapper {

	static var localization: DocumentLocalizationProtocol {
		return DocumentLocalization()
	}

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
			return localization.unexpectedFormatErrorReason
		case .unknownVersion:
			return localization.unknownVersionErrorReason
		}
	}
}
