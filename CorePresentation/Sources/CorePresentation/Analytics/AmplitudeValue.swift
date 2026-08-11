//
//  AmplitudeValue.swift
//  CorePresentation
//

import Analytics

enum AmplitudeValue: Encodable {

	case string(String)
	case int(Int)
	case double(Double)
	case bool(Bool)

	init(value: AnalyticsValue) {
		switch value {
		case let .string(value):
			self = .string(value)
		case let .int(value):
			self = .int(value)
		case let .double(value):
			self = .double(value)
		case let .bool(value):
			self = .bool(value)
		}
	}
}

// MARK: - Encodable
extension AmplitudeValue {

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case let .string(value):
			try container.encode(value)
		case let .int(value):
			try container.encode(value)
		case let .double(value):
			try container.encode(value)
		case let .bool(value):
			try container.encode(value)
		}
	}
}
