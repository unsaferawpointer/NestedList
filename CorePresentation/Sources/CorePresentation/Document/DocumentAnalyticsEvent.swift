//
//  DocumentAnalyticsEvent.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 20.07.2026.
//

import Analytics
import CoreModule

/// Analytics events produced by the document unit.
///
/// Keep case raw semantics stable through the `AnalyticsEvent.name` and
/// `AnalyticsEvent.parameters` implementations below: these values are consumed by the
/// analytics backend and should only change as part of an explicit analytics schema migration.
public enum DocumentAnalyticsEvent {

	/// Document was read successfully.
	///
	/// - Parameter type: Stable document type identifier.
	case read(type: String)

	/// Document reading failed while loading its contents.
	///
	/// - Parameter error: Reason the document could not be read.
	case readError(DocumentError)

	/// User clicked a document toolbar button.
	///
	/// - Parameter id: Stable button identifier.
	case buttonClick(id: String)
}

// MARK: - AnalyticsEvent
extension DocumentAnalyticsEvent: AnalyticsEvent {

	/// Stable analytics area for all document unit events.
	public var area: String { "document" }

	/// Stable analytics backend event name.
	public var name: AnalyticsEventName {
		switch self {
		case .read:
			.documentRead
		case .readError:
			.documentReadError
		case .buttonClick:
			.buttonClick
		}
	}

	/// Typed analytics parameters sent with the event.
	public var parameters: [String: AnalyticsValue] {
		switch self {
		case let .read(type):
			[
				"type": .string(type)
			]
		case let .readError(error):
			[
				"reason": .string(reason(for: error))
			]
		case let .buttonClick(id):
			[
				"id": .string(id)
			]
		}
	}
}

// MARK: - Helpers
private extension DocumentAnalyticsEvent {

	/// Stable machine-readable reason for the read error.
	func reason(for error: DocumentError) -> String {
		switch error {
		case .unexpectedFormat:
			"unexpected_format"
		case .unknownVersion:
			"unknown_version"
		}
	}
}
