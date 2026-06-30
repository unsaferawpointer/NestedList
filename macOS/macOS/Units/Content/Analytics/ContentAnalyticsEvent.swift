//
//  ContentAnalyticsEvent.swift
//  Nested List
//
//  Created by Anton Cherkasov on 30.06.2026.
//

import Analytics

enum ContentAnalyticsEvent {
	case menuClick(id: String, source: String)
	case documentShow(depth: Int, totalCount: Int)
	case subitemsShow(indent: Int)
	case buttonClick(id: String, source: String)
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
		}
	}

	var parameters: [String: AnalyticsValue] {
		switch self {
		case let .menuClick(id, source):
			[
				"id": .string(id),
				"source": .string(source)
			]
		case let .documentShow(depth, totalCount):
			[
				"depth": .int(depth),
				"total_count": .int(totalCount)
			]
		case let .subitemsShow(indent):
			[
				"indent": .int(indent)
			]
		case let .buttonClick(id, source):
			[
				"id": .string(id),
				"source": .string(source)
			]
		}
	}
}
