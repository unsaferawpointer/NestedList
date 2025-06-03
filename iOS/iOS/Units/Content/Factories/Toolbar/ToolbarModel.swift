//
//  ToolbarModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 17.03.2025.
//

import DesignSystem

struct ToolbarModel {
	var top: [ToolbarItem] = []
	var bottom: [ToolbarItem] = []
}

//extension ToolbarModel {
//
//	struct Item {
//
//		var id: Identifier
//		var isEnabled: Bool
//
//		init(id: Identifier, isEnabled: Bool = true) {
//			self.id = id
//			self.isEnabled = isEnabled
//		}
//	}
//
//	enum Identifier {
//		case flexibleSpace
//		case markAsComplete
//		case delete
//		case createNew
//		case done
//		case more
//		case status(title: String)
//	}
//}
