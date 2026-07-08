//
//  ContentToolbarConfiguration.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.07.2026.
//

import Foundation

struct ContentToolbarConfiguration<ID: Hashable> {
	var editingMode: EditingMode?
	var selection: [ID]
	var isCompleted: Bool?
	var isSubitemsHidden: Bool?

	// MARK: - Initialization

	init(editingMode: EditingMode?, selection: [ID], isCompleted: Bool?, isSubitemsHidden: Bool?) {
		self.editingMode = editingMode
		self.selection = selection
		self.isCompleted = isCompleted
		self.isSubitemsHidden = isSubitemsHidden
	}
}

// MARK: - Computed properties
extension ContentToolbarConfiguration {

	var showUndoGroup: Bool {
		editingMode == nil
	}
}
