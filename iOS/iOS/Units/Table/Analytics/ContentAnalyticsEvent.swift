//
//  ContentAnalyticsEvent.swift
//  iOS
//
//  Created by Anton Cherkasov on 11.07.2026.
//

import Analytics

enum ContentAnalyticsEvent {
	case menuClick(id: String, source: String)
	case documentShow(depth: Int, totalCount: Int, isRoot: Bool)
	case subitemsShow
	case buttonClick(id: String, source: String)
	case itemDoubleClick
	case dragDropMove(itemsCount: Int)
	case dragDropCopy(itemsCount: Int)
	case dragDropDrop(itemsCount: Int, contentType: String)
}

// MARK: - AnalyticsEvent
extension ContentAnalyticsEvent: AnalyticsEvent {

	var area: String { "content" }

	var name: String {
		switch self {
		case .menuClick:
			"menu_click"
		case .documentShow:
			"document_show"
		case .subitemsShow:
			"subitems_show"
		case .buttonClick:
			"button_click"
		case .itemDoubleClick:
			"item_double_click"
		case .dragDropMove:
			"drag_drop_move"
		case .dragDropCopy:
			"drag_drop_copy"
		case .dragDropDrop:
			"drag_drop_drop"
		}
	}

	var parameters: [String: AnalyticsValue] {
		switch self {
		case let .menuClick(id, source):
			[
				"id": .string(id),
				"source": .string(source)
			]
		case let .documentShow(depth, totalCount, isRoot):
			[
				"depth": .int(depth),
				"total_count": .int(totalCount),
				"isRoot": .bool(isRoot)
			]
		case .subitemsShow:
			[:]
		case let .buttonClick(id, source):
			[
				"id": .string(id),
				"source": .string(source)
			]
		case .itemDoubleClick:
			[:]
		case let .dragDropMove(itemsCount):
			[
				"items_count": .int(itemsCount)
			]
		case let .dragDropCopy(itemsCount):
			[
				"items_count": .int(itemsCount)
			]
		case let .dragDropDrop(itemsCount, contentType):
			[
				"items_count": .int(itemsCount),
				"content_type": .string(contentType)
			]
		}
	}
}
