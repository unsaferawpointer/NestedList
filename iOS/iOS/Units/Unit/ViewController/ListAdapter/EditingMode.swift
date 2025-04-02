//
//  EditingMode.swift
//  iOS
//
//  Created by Anton Cherkasov on 19.03.2025.
//

enum EditingMode {
	case selection
	case reordering
}

// MARK: - Computed properties
extension EditingMode {

	var allowSelection: Bool {
		guard self == .selection else {
			return false
		}
		return true
	}
}
