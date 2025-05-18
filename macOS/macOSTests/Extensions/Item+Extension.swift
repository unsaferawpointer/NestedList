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
			text: .random,
			note: .random,
			options: []
		)
	}
}
