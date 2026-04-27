//
//  ItemColorTests.swift
//  CoreModuleTests
//

import Testing
@testable import CoreModule

struct ItemColorTests { }

// MARK: - testing ItemColor
extension ItemColorTests {

	@Test func rawValueForEachColor() {
		for (color, expectedRawValue) in colorCases {
			checkRawValue(color, expectedRawValue: expectedRawValue)
		}
	}

	@Test func initFromRawValueForEachColor() {
		for (expectedColor, rawValue) in colorCases {
			checkItemColor(rawValue, expectedColor: expectedColor)
		}
	}

	@Test func initFromUnknownRawValue() {
		checkItemColor(-1, expectedColor: .unknown(-1))
		checkItemColor(999, expectedColor: .unknown(999))
		checkRawValue(.unknown(-1), expectedRawValue: -1)
		checkRawValue(.unknown(999), expectedRawValue: 999)
	}

	@Test func allCasesCount() {
		#expect(ItemColor.allCases.count == colorCases.count)
	}
}

// MARK: - Helpers
private extension ItemColorTests {

	func checkRawValue(_ color: ItemColor, expectedRawValue: Int) {
		#expect(color.rawValue == expectedRawValue)
	}

	func checkItemColor(_ rawValue: Int, expectedColor: ItemColor) {
		#expect(ItemColor(rawValue: rawValue) == expectedColor)
	}

	var colorCases: [(color: ItemColor, rawValue: Int)] {
		[
			(.accent, 1),
			(.primary, 2),
			(.secondary, 3),
			(.tertiary, 4),
			(.quaternary, 5),
			(.red, 10),
			(.coral, 23),
			(.orange, 11),
			(.yellow, 12),
			(.yellowGreen, 24),
			(.green, 13),
			(.mint, 14),
			(.teal, 15),
			(.cyan, 16),
			(.blue, 17),
			(.indigo, 18),
			(.purple, 19),
			(.pink, 20),
			(.brown, 21)
		]
	}
}
