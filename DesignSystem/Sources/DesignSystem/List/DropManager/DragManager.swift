//
//  DragManager.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 03.03.2025.
//

#if canImport(AppKit)
import AppKit

final class DragManager<ID: Encodable> {

	unowned var list: NSOutlineView

	weak var delegate: (any DragDelegate<ID>)?

	// MARK: - Initialization

	init(list: NSOutlineView) {
		self.list = list
	}
}

// MARK: - Public interface
extension DragManager {

	func write(_ id: ID, to pasteboardItem: NSPasteboardItem) -> NSPasteboardWriting? {

		let encoder = JSONEncoder()

		guard let data = try? encoder.encode(id) else {
			return nil
		}

		pasteboardItem.setData(data, forType: .identifier)
		return pasteboardItem
	}

	func draggingWillBegin(draggingSession session: NSDraggingSession, forItems ids: [ID]) {

		precondition(session.draggingPasteboard.pasteboardItems?.count == ids.count)

		let pasteboard = Pasteboard(pasteboard: session.draggingPasteboard)
		delegate?.write(ids: ids, to: pasteboard)
	}

}

extension NSPasteboard.PasteboardType {

	static let identifier: Self = .init("dev.zeroindex.ListAdapter.identifier")
}
#endif
