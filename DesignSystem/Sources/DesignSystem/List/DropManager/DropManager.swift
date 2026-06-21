//
//  DropManager.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.06.2025.
//

#if os(macOS)
import AppKit
import Hierarchy

@MainActor
final class DropManager<ID: Decodable> {

	unowned var list: NSOutlineView

	weak var delegate: (any DropDelegate<ID>)? {
		didSet {
			register()
		}
	}

	// MARK: - Initialization

	init(list: NSOutlineView) {
		self.list = list
	}
}

// MARK: - Public Interface
extension DropManager {

	func validateDrop(info: NSDraggingInfo, to destination: Destination<ID>) -> NSDragOperation {

		guard let delegate else {
			return []
		}

		if isLocal(from: info) {
			guard info.draggingSourceOperationMask == .copy else {
				let ids: [ID] = info.objects(objectType: ID.self, with: .identifier)
				let isValid = delegate.validateMovement(ids, to: destination)
				return isValid ? .private : []
			}
			return .copy
		}

		guard let info = Pasteboard(pasteboard: info.draggingPasteboard).getInfo() else {
			return []
		}

		return delegate.validateDrop(info, to: destination) ? .copy : []
	}

	func acceptDrop(info: NSDraggingInfo, to destination: Destination<ID>) -> Bool {

		guard let delegate else {
			return false
		}

		guard !isLocal(from: info) else {
			let ids: [ID] = info.objects(objectType: ID.self, with: .identifier)
			if info.draggingSourceOperationMask == .copy {
				delegate.copy(ids, to: destination)
			} else {
				delegate.move(ids, to: destination)
			}
			return true
		}

		guard let info = Pasteboard(pasteboard: info.draggingPasteboard).getInfo() else {
			return false
		}

		delegate.drop(info, to: destination)
		return true
	}
}

// MARK: - Helpers
private extension DropManager {

	func isLocal(from info: NSDraggingInfo) -> Bool {
		guard
			let source = info.draggingSource as? NSOutlineView,
			let sourceWindow = source.window, let destinationWindow = list.window
		else {
			return false
		}

		return areRelated(window: sourceWindow, to: destinationWindow)
	}

	func areRelated(window lhs: NSWindow, to rhs: NSWindow) -> Bool {
		let lhsHierarchy = windowHierarchy(from: lhs)
		let rhsHierarchy = windowHierarchy(from: rhs)

		return lhsHierarchy.contains { lhsWindow in
			rhsHierarchy.contains { rhsWindow in
				lhsWindow === rhsWindow
			}
		}
	}

	func windowHierarchy(from window: NSWindow) -> [NSWindow] {
		var hierarchy = [window]
		var current = window

		while let parent = current.parent {
			hierarchy.append(parent)
			current = parent
		}

		return hierarchy
	}

	func register() {

		list.unregisterDraggedTypes()

		let availableTypes = delegate?.availableTypes().map {
			NSPasteboard.PasteboardType($0)
		}

		guard let availableTypes else {
			return
		}

		list.registerForDraggedTypes([.identifier] + availableTypes)
		list.setDraggingSourceOperationMask(.copy, forLocal: false)
	}
}
#endif
