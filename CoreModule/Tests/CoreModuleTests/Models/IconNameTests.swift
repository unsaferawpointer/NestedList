//
//  IconNameTests.swift
//  CoreModuleTests
//

import Testing
@testable import CoreModule

struct IconNameTests { }

// MARK: - testing IconName
extension IconNameTests {

	@Test func rawValueForEachIcon() {
		for (icon, expectedRawValue) in iconCases {
			checkRawValue(icon, expectedRawValue: expectedRawValue)
		}
	}

	@Test func initFromRawValueForEachIcon() {
		for (expectedIcon, rawValue) in iconCases {
			checkIconName(rawValue, expectedIcon: expectedIcon)
		}
	}

	@Test func initFromUnknownRawValue() {
		checkIconName(-1, expectedIcon: .unknown(-1))
		checkIconName(999, expectedIcon: .unknown(999))
		checkRawValue(.unknown(-1), expectedRawValue: -1)
		checkRawValue(.unknown(999), expectedRawValue: 999)
	}

	@Test func allCasesCount() {
		#expect(IconName.allCases.count == iconCases.count)
	}
}

// MARK: - Helpers
private extension IconNameTests {

	func checkRawValue(_ icon: IconName, expectedRawValue: Int) {
		#expect(icon.rawValue == expectedRawValue)
	}

	func checkIconName(_ rawValue: Int, expectedIcon: IconName) {
		#expect(IconName(rawValue: rawValue) == expectedIcon)
	}

	var iconCases: [(icon: IconName, rawValue: Int)] {
		[
			(.document, 10),
			(.documents, 11),
			(.folder, 12),
			(.package, 13),
			(.archivebox, 14),
			(.stack, 15),
			(.book, 16),
			(.squareGrid2x2, 17),
			(.listStar, 18),
			(.person, 19),
			(.cloud, 20),
			(.sun, 21),
			(.moonStars, 67),
			(.sparkles, 22),
			(.flame, 23),
			(.creditcard, 24),
			(.gift, 25),
			(.trash, 27),
			(.receipt, 29),
			(.terminal, 31),
			(.calendar, 32),
			(.clock, 68),
			(.xmarkApp, 78),
			(.checkmarkApp, 81),
			(.xmarkDiamond, 82),
			(.checkmarkDiamond, 83),
			(.pc, 70),
			(.location, 71),
			(.bookmark, 72),
			(.tag, 73),
			(.squareOnSquare, 35),
			(.insetDiamond, 37),
			(.bell, 38),
			(.conversation, 40),
			(.envelope, 42),
			(.gearshape, 43),
			(.suitcase, 47),
			(.key, 50),
			(.airplane, 52),
			(.carRear, 53),
			(.film, 54),
			(.photo, 55),
			(.photoOnRectangle, 56),
			(.insetCircle, 61),
			(.insetSquare, 62),
			(.personGroup, 63),
			(.leaf, 64),
			(.house, 65),
			(.insetTriangle, 66),
			(.star, 100),
			(.heart, 101),
			(.bolt, 102)
		]
	}
}
