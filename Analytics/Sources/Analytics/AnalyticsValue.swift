//
//  AnalyticsValue.swift
//  Analytics
//

import Foundation

/// A typed analytics parameter value.
///
/// Use this type for event parameters to keep analytics payloads limited to primitive,
/// backend-friendly values while preserving Swift type safety at call sites.
public enum AnalyticsValue: Sendable, Equatable, Codable {

	/// String parameter value.
	case string(String)

	/// Integer parameter value.
	case int(Int)

	/// Floating-point parameter value.
	case double(Double)

	/// Boolean parameter value.
	case bool(Bool)
}

// MARK: - ExpressibleByStringLiteral
extension AnalyticsValue: ExpressibleByStringLiteral {

	/// Creates a string analytics value from a string literal.
	public init(stringLiteral value: String) {
		self = .string(value)
	}
}

// MARK: - ExpressibleByIntegerLiteral
extension AnalyticsValue: ExpressibleByIntegerLiteral {

	/// Creates an integer analytics value from an integer literal.
	public init(integerLiteral value: Int) {
		self = .int(value)
	}
}

// MARK: - ExpressibleByFloatLiteral
extension AnalyticsValue: ExpressibleByFloatLiteral {

	/// Creates a floating-point analytics value from a float literal.
	public init(floatLiteral value: Double) {
		self = .double(value)
	}
}

// MARK: - ExpressibleByBooleanLiteral
extension AnalyticsValue: ExpressibleByBooleanLiteral {

	/// Creates a boolean analytics value from a boolean literal.
	public init(booleanLiteral value: Bool) {
		self = .bool(value)
	}
}
