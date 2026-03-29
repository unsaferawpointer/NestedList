//
//  String + Extension.swift
//  iOSTests
//
//  Created by Anton Cherkasov on 18.03.2026.
//

import Foundation

extension String {

	static var random: String {
		UUID().uuidString
	}
}
