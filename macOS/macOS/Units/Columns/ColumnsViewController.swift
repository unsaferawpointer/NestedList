//
//  ColumnsViewController.swift
//  Nested List
//
//  Created by Anton Cherkasov on 14.08.2025.
//

import AppKit
import DesignSystem

protocol ColumnsViewOutput: ViewDelegate { }

protocol ColumnsUnitView: AnyObject { }

class ColumnsViewController: NSViewController {

	// MARK: - DI

	var output: ColumnsViewOutput?

	// MARK: - Initialization

	init(configure: (ColumnsViewController) -> Void) {
		super.init(nibName: nil, bundle: nil)
		configure(self)
	}

	@available(*, unavailable, message: "Use init(storage:)")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - ColumnsUnitView
extension ColumnsViewController: ColumnsUnitView {

}
