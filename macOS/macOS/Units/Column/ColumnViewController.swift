//
//  ColumnViewController.swift
//  macOS
//

import AppKit

/// The Column view interface.
protocol ColumnUnitView: AnyObject { }

/// The Column view controller.
final class ColumnViewController: NSViewController {

	var output: (any ColumnViewOutput)?
}

// MARK: - ColumnUnitView
extension ColumnViewController: ColumnUnitView { }
