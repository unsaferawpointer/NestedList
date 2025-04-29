//
//  Item+Extension.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 25.01.2025.
//

import CoreModule

extension Item {

	static var random: Item {
		return .init(
			uuid: .init(),
			isStrikethrough: Bool.random(),
			isMarked: Bool.random(),
			text: .random,
			note: .random,
			style: .item
		)
	}
}
