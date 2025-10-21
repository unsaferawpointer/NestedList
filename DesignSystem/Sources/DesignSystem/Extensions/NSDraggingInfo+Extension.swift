//
//  NSDraggingInfo+Extension.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.06.2025.
//

#if os(macOS)
import AppKit

extension NSDraggingInfo {

	func objects<O: Decodable>(objectType: O.Type, with type: NSPasteboard.PasteboardType) -> [O] {
		guard let items = draggingPasteboard.pasteboardItems else {
			return []
		}

		let decoder = JSONDecoder()

		return items.compactMap { item in
			item.data(forType: type)
		}.compactMap { data in
			return try? decoder.decode(O.self, from: data)
		}
	}
}
#endif
