//
//  MenuModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.03.2025.
//

import Foundation

struct MenuModel {
	var identifiers: [Identifier] = []
}

extension MenuModel {

	enum Identifier {
		case edit
		case createNew
		case cut
		case copy
		case paste
		case status
		case style
	}
}
