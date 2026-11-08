import Foundation
import Hierarchy
@testable import iOS

final class ContentViewMock {

	private(set) var snapshot = Snapshot<ItemModel>()
	private(set) var path: [PathItem] = []
	private(set) var title: String?
	private(set) var didExpandAll = false
	var stubs = Stubs()
}

// MARK: - ContentView
extension ContentViewMock: ContentView {

	var selection: [UUID] { stubs.selection }

	func display(_ snapshot: Snapshot<ItemModel>) {
		self.snapshot = snapshot
	}

	func display(title: String) {
		self.title = title
	}

	func displayPath(_ items: [PathItem]) {
		path = items
	}

	func expandAll() {
		didExpandAll = true
	}

	func apply(_ configuration: ContentToolbarConfiguration<UUID>) { }
	func setEditing(_ editingMode: EditingMode?) { }
	func scroll(to id: UUID) { }
	func expand(_ id: UUID) { }
	func collapseAll() { }
	func selectAll() { }
}

// MARK: - Nested data structs
extension ContentViewMock {

	struct Stubs {
		var selection: [UUID] = []
	}
}
