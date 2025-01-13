//
//  String+Extension.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 12.01.2025.
//

import Foundation

extension String {

	static var random: String {
		UUID().uuidString
	}
}
