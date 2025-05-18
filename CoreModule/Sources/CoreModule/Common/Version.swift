//
//  Version.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation

/// - Note: **format** `major.minor.patch`
public struct Version {

	public let major: Int
	public let minor: Int
	public let patch: Int

	// MARK: - Initialization block

	init(major: Int, minor: Int = 0, patch: Int = 0) {
		self.major = major
		self.minor = minor
		self.patch = patch
	}

}

// MARK: - RawRepresentable
extension Version: RawRepresentable {

	public var rawValue: String {
		return "\(major).\(minor).\(patch)"
	}

	public init?(rawValue: String) {

		let modificated = rawValue.trimmingPrefix("v")

		let components = modificated.split(separator: ".")
		guard let majorComponent = components.first, let major = Int(majorComponent) else {
			return nil
		}

		self.major = major

		if let minorComponent = components.dropFirst().first {
			self.minor = Int(minorComponent) ?? 0
		} else {
			self.minor = 0
		}

		if let patchComponent = components.dropFirst(2).first {
			self.patch = Int(patchComponent) ?? 0
		} else {
			self.patch = 0
		}
	}
}

// MARK: - Codable
extension Version: Codable { }

// MARK: - Comparable
extension Version: Comparable {

	public static func < (lhs: Version, rhs: Version) -> Bool {
		[(lhs.major, rhs.major), (lhs.minor, rhs.minor), (lhs.patch, rhs.patch)]
			.compactMap { lhs, rhs in
				compare(lhs: lhs, rhs: rhs)
			}.first ?? false
	}

	static func compare(lhs: Int, rhs: Int) -> Bool? {
		guard lhs != rhs else {
			return nil
		}
		return lhs < rhs
	}
}
