//
//  ContentAnalyticsEvent.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 11.07.2026.
//

import Analytics

/// Analytics events produced by the content screen.
///
/// Keep case raw semantics stable through the `AnalyticsEvent.name` and
/// `AnalyticsEvent.parameters` implementations below: these values are consumed by the
/// analytics backend and should only change as part of an explicit analytics schema migration.
public enum ContentAnalyticsEvent {

	/// User selected an item from a context or app menu.
	///
	/// - Parameters:
	///   - id: Stable menu item identifier, usually `ContentMenuIdentifier.rawValue`.
	///   - source: Menu surface where the click originated.
	case menuClick(id: String, source: String)

	/// Content document became visible to the user.
	///
	/// - Parameters:
	///   - depth: Nesting depth of the displayed document.
	///   - totalCount: Number of items in the displayed document snapshot.
	///   - isRoot: Whether the displayed document is the root document.
	case documentShow(depth: Int, totalCount: Int, isRoot: Bool)

	/// User expanded hidden subitems from the content screen.
	case subitemsShow

	/// User clicked a toolbar or other button on the content screen.
	///
	/// - Parameters:
	///   - id: Stable button identifier.
	///   - source: UI surface where the click originated, for example `toolbar`.
	case buttonClick(id: String, source: String)

	/// User moved items through drag and drop.
	///
	/// - Parameter itemsCount: Number of moved items.
	case dragDropMove(itemsCount: Int)

	/// User inserted external or pasteboard content into the document through drag and drop.
	///
	/// - Parameters:
	///   - itemsCount: Number of inserted items produced by the drop.
	///   - contentType: Type of dropped content, such as text or serialized item data.
	case dragDropInsert(itemsCount: Int, contentType: String)

	#if os(macOS)
	/// User opened an item by double-clicking it in the macOS content outline.
	case itemDoubleClick

	/// User copied items through drag and drop on macOS.
	///
	/// - Parameter itemsCount: Number of copied items.
	case dragDropCopy(itemsCount: Int)
	#endif
}

// MARK: - AnalyticsEvent
extension ContentAnalyticsEvent: AnalyticsEvent {

	/// Stable analytics area for all content screen events.
	public var area: String { "content" }

	/// Stable analytics backend event name.
	public var name: AnalyticsEventName {
		switch self {
		case .menuClick:
			.menuItemClick
		case .documentShow:
			.screenShow
		case .subitemsShow, .buttonClick:
			.buttonClick
		case .dragDropMove:
			.dragDropMove
		case .dragDropInsert:
			.dragDropInsert

		#if os(macOS)
		case .itemDoubleClick:
			.buttonClick
		case .dragDropCopy:
			.dragDropCopy
		#endif
		}
	}

	/// Typed analytics parameters sent with the event.
	public var parameters: [String: AnalyticsValue] {
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
				"is_root": .bool(isRoot)
			]
		case .subitemsShow:
			[
				"id": .string("show_subitems")
			]
		case let .buttonClick(id, source):
			[
				"id": .string(id),
				"source": .string(source)
			]
		case let .dragDropMove(itemsCount):
			[
				"items_count": .int(itemsCount)
			]
		case let .dragDropInsert(itemsCount, contentType):
			[
				"items_count": .int(itemsCount),
				"content_type": .string(contentType)
			]

		#if os(macOS)
		case .itemDoubleClick:
			[
				"id": .string("open_item")
			]
		case let .dragDropCopy(itemsCount):
			[
				"items_count": .int(itemsCount)
			]
		#endif
		}
	}
}
