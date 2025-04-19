//
//  Settings+Extension.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 13.03.2025.
//

import CoreSettings

extension Settings {

	static var standart: Self {
		return .init(
			completionBehaviour: .regular,
			markingBehaviour: .regular
		)
	}
}
