//
//  DragManager.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 03.03.2025.
//

import AppKit

final class DragManager { }

// MARK: - Public interface
extension DragManager {

	static func registerTypes(in list: NSTableView) {
		list.registerForDraggedTypes([.identifier, .string])
		list.setDraggingSourceOperationMask(.copy, forLocal: false)
	}

	static func isLocal(from info: NSDraggingInfo, in list: NSOutlineView) -> Bool {
		guard let source = info.draggingSource as? NSOutlineView else {
			return false
		}
		return source === list
	}

	static func identifiers<ID: Decodable>(from info: NSDraggingInfo) -> [ID] {

		guard let pasteboardItems = info.draggingPasteboard.pasteboardItems else {
			return []
		}

		let decoder = JSONDecoder()

		return pasteboardItems.compactMap { item in
			item.data(forType: .identifier)
		}.compactMap { data in
			return try? decoder.decode(ID.self, from: data)
		}
	}

	static func write<ID: Encodable>(_ id: ID, to pasteboardItem: NSPasteboardItem) -> NSPasteboardWriting? {

		let encoder = JSONEncoder()

		guard let data = try? encoder.encode(id) else {
			return nil
		}

		pasteboardItem.setData(data, forType: .identifier)
		return pasteboardItem
	}

}

private extension NSPasteboard.PasteboardType {

	static let identifier: Self = .init("dev.zeroindex.ListAdapter.identifier")
}
