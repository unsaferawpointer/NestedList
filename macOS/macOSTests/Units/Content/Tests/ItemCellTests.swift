import AppKit
import CoreModule
import DesignSystem
import Hierarchy
import Testing

@testable import Nested_List

@MainActor
struct ItemCellTests {}

// MARK: - Automatic row height
extension ItemCellTests {

	@Test(arguments: [false, true], [false, true])
	func layout_preservesTextAndShrinksAfterRemovingNote(
		showsIcon: Bool,
		showsDisclosure: Bool
	) {
		// Arrange
		let fixture = LayoutFixture(showsIcon: showsIcon, showsDisclosure: showsDisclosure)

		// Act
		let initial = fixture.layout(subtitle: nil)
		let withNote = fixture.layout(subtitle: "Note")
		let withoutNote = fixture.layout(subtitle: nil)
		let withNoteAgain = fixture.layout(subtitle: "Another note")
		let withoutNoteAgain = fixture.layout(subtitle: nil)

		// Assert
		for layout in [withNote, withNoteAgain] {
			#expect(layout.height > initial.height)
			#expect(layout.titleFrame.height >= fixture.cell.titleTextfield.intrinsicContentSize.height)
			#expect(layout.subtitleFrame.height >= fixture.cell.subtitleTextfield.intrinsicContentSize.height)
			#expect(!layout.titleFrame.intersects(layout.subtitleFrame))
			let gap = max(layout.titleFrame.minY, layout.subtitleFrame.minY)
				- min(layout.titleFrame.maxY, layout.subtitleFrame.maxY)
			#expect(gap >= 2)
		}
		#expect(withoutNote.height == initial.height)
		#expect(withoutNoteAgain.height == initial.height)
	}

	@Test(arguments: [false, true], [false, true])
	func layout_wrapsBothFieldsAndShrinksWhenTextShortens(showsIcon: Bool, showsDisclosure: Bool) {
		// Arrange
		let fixture = LayoutFixture(showsIcon: showsIcon, showsDisclosure: showsDisclosure)
		let longText = String(repeating: "Long text that wraps onto several lines. ", count: 10)

		// Act
		let initial = fixture.layout(subtitle: "Note")
		let expanded = fixture.layout(title: longText, subtitle: longText)
		let shortened = fixture.layout(subtitle: "Note")

		// Assert
		#expect(expanded.titleFrame.height > initial.titleFrame.height)
		#expect(expanded.subtitleFrame.height > initial.subtitleFrame.height)
		#expect(expanded.height > initial.height)
		#expect(!expanded.titleFrame.intersects(expanded.subtitleFrame))
		#expect(expanded.titleFrame.width == expanded.subtitleFrame.width)
		#expect(fixture.cell.titleTextfield.alignmentRect(forFrame: expanded.titleFrame).maxX <= 400)
		#expect(shortened.height == initial.height)
	}

	@Test(arguments: [false, true])
	func layout_recalculatesBothFieldsWhenWidthChanges(showsIcon: Bool) {
		// Arrange
		let fixture = LayoutFixture(showsIcon: showsIcon)
		let text = String(repeating: "Text with wrapping. ", count: 10)

		// Act
		let wide = fixture.layout(title: text, subtitle: text, width: 600)
		let narrow = fixture.layout(title: text, subtitle: text, width: 180)
		let widened = fixture.layout(title: text, subtitle: text, width: 600)

		// Assert
		#expect(narrow.titleFrame.height > wide.titleFrame.height)
		#expect(narrow.subtitleFrame.height > wide.subtitleFrame.height)
		#expect(narrow.height > wide.height)
		#expect(fixture.cell.titleTextfield.alignmentRect(forFrame: narrow.titleFrame).maxX <= 180)
		#expect(fixture.cell.subtitleTextfield.alignmentRect(forFrame: narrow.subtitleFrame).maxX <= 180)
		#expect(!narrow.titleFrame.intersects(narrow.subtitleFrame))
		#expect(widened.height == wide.height)
	}

	@Test func layout_respectsExplicitLineBreaks() {
		// Arrange
		let fixture = LayoutFixture()

		// Act
		let singleLine = fixture.layout(subtitle: "Note")
		let multipleLines = fixture.layout(title: "First\nSecond\nThird", subtitle: "First\nSecond")

		// Assert
		#expect(multipleLines.titleFrame.height >= singleLine.titleFrame.height * 3)
		#expect(multipleLines.subtitleFrame.height >= singleLine.subtitleFrame.height * 2)
		#expect(!multipleLines.titleFrame.intersects(multipleLines.subtitleFrame))
	}

	@Test func outlineView_recalculatesRowHeightAfterTextChanges() {
		// Arrange
		let fixture = OutlineFixture()
		defer { fixture.window.close() }
		let text = String(repeating: "Long text that wraps. ", count: 10)

		// Act
		let initialHeight = fixture.height()
		fixture.cell.model.value = .init(title: text, subtitle: text)
		let expandedHeight = fixture.height()
		fixture.cell.model.value = .init(title: "Title", subtitle: nil)
		let shortenedHeight = fixture.height()

		// Assert
		#expect(expandedHeight > initialHeight)
		#expect(abs(shortenedHeight - initialHeight) < 0.001)
		#expect(abs(fixture.cell.frame.height - shortenedHeight) < 1)
	}
}

// MARK: - Spacer rows
extension ItemCellTests {

	@Test func outlineView_adapterUsesSpacerViewsWithHeightsForEachLevel() throws {
		// Arrange
		let fixture = OutlineFixture()
		defer { fixture.window.close() }
		let adapter = ListAdapter<ItemModel>(tableView: fixture.outline)
		fixture.outline.reloadData()
		var group = Self.makeModel()
		group.isGroup = true
		var nestedGroup = Self.makeModel()
		nestedGroup.isGroup = true
		let snapshot = Snapshot([
			DocumentNode(value: Self.makeModel(), children: []),
			DocumentNode(value: group, children: [DocumentNode(value: nestedGroup, children: [])])
		])

		// Act
		adapter.apply(snapshot)
		fixture.outline.expandItem(nil, expandChildren: true)
		let rootSpacer = fixture.outline.view(atColumn: 0, row: 1, makeIfNecessary: true) as? SpacerView
		let nestedSpacer = fixture.outline.view(atColumn: 0, row: 3, makeIfNecessary: true) as? SpacerView
		_ = fixture.height()

		// Assert
		try withExtendedLifetime(adapter) {
			let rootSpacer = try #require(rootSpacer)
			let nestedSpacer = try #require(nestedSpacer)
			#expect(fixture.outline.numberOfRows == 5)
			#expect(rootSpacer.intrinsicContentSize.height == 8)
			#expect(nestedSpacer.intrinsicContentSize.height == 4)
			#expect(abs(fixture.outline.rect(ofRow: 1).height - 8) < 0.001)
			#expect(abs(fixture.outline.rect(ofRow: 3).height - 4) < 0.001)
		}
	}
}

// MARK: - Inline editing
extension ItemCellTests {

	@Test(arguments: [false, true])
	func editing_recalculatesHeightBeforeCommitting(editsSubtitle: Bool) throws {
		// Arrange
		let fixture = LayoutFixture()
		let initial = fixture.layout(subtitle: "Note")
		let window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
			styleMask: [.titled],
			backing: .buffered,
			defer: false
		)
		window.isReleasedWhenClosed = false
		defer { window.close() }
		window.contentView?.addSubview(fixture.row)
		let field = editsSubtitle ? fixture.cell.subtitleTextfield : fixture.cell.titleTextfield
		field.selectText(nil)
		let editor = try #require(field.currentEditor())
		let originalText = field.stringValue
		let notification = Notification(name: NSText.didChangeNotification, object: editor)

		// Act
		editor.string = String(repeating: "Text entered before committing. ", count: 10)
		field.textDidChange(notification)
		let expanded = fixture.measure()
		editor.string = originalText
		field.textDidChange(notification)
		let shortened = fixture.measure()

		// Assert
		#expect(expanded.height > initial.height)
		#expect(shortened.height == initial.height)
		#expect(fixture.cell.model.value.title == "Title")
		#expect(fixture.cell.model.value.subtitle == "Note")
	}
}

// MARK: - Nested data structs
private extension ItemCellTests {

	static func makeModel(showsIcon: Bool = true, showsDisclosure: Bool = true) -> ItemModel {
		ItemModel(
			id: UUID(),
			value: .init(title: "Title", subtitle: nil),
			configuration: .init(
				compositeIcon: showsIcon ? .init(icon: .init(name: .point, token: .primary), badge: nil) : nil,
				text: .init(style: .body, colorToken: .primary, strikethrough: false),
				showsTrailingDisclosure: showsDisclosure
			),
			isGroup: false,
			height: nil
		)
	}

	struct Layout {
		let height: CGFloat
		let titleFrame: NSRect
		let subtitleFrame: NSRect
	}

	@MainActor
	final class LayoutFixture {

		let cell: ItemCell
		let row: NSTableRowView
		let cachedHeight: NSLayoutConstraint

		init(showsIcon: Bool = true, showsDisclosure: Bool = true) {
			let model = ItemCellTests.makeModel(showsIcon: showsIcon, showsDisclosure: showsDisclosure)
			cell = ItemCell(model)
			row = NSTableRowView(frame: NSRect(x: 0, y: 0, width: 400, height: 24))
			cell.translatesAutoresizingMaskIntoConstraints = false
			row.addSubview(cell)
			NSLayoutConstraint.activate([
				cell.topAnchor.constraint(equalTo: row.topAnchor),
				cell.bottomAnchor.constraint(equalTo: row.bottomAnchor),
				cell.leadingAnchor.constraint(equalTo: row.leadingAnchor),
				cell.trailingAnchor.constraint(equalTo: row.trailingAnchor)
			])
			// Match AppKit's NSTableRowView_Encapsulated_Layout_Height constraint.
			cachedHeight = row.heightAnchor.constraint(equalToConstant: 24)
			cachedHeight.priority = .init(500)
			cachedHeight.isActive = true
		}

		func layout(title: String = "Title", subtitle: String?, width: CGFloat = 400) -> Layout {
			cell.model.value = .init(title: title, subtitle: subtitle)
			return measure(width: width)
		}

		func measure(width: CGFloat = 400) -> Layout {
			row.setFrameSize(NSSize(width: width, height: row.frame.height))
			row.layoutSubtreeIfNeeded()
			let height = row.fittingSize.height
			cachedHeight.constant = height
			row.setFrameSize(NSSize(width: width, height: height))
			row.layoutSubtreeIfNeeded()
			return Layout(
				height: height,
				titleFrame: cell.titleTextfield.convert(cell.titleTextfield.bounds, to: row),
				subtitleFrame: cell.subtitleTextfield.convert(cell.subtitleTextfield.bounds, to: row)
			)
		}
	}

	@MainActor
	final class OutlineFixture: NSObject {

		let cell = ItemCell(ItemCellTests.makeModel())
		let outline = NSOutlineView.standart
		let item = NSObject()
		let window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
			styleMask: [.titled],
			backing: .buffered,
			defer: false
		)

		override init() {
			super.init()
			window.isReleasedWhenClosed = false
			let column = NSTableColumn(identifier: .init("content"))
			column.width = 400
			outline.addTableColumn(column)
			outline.dataSource = self
			outline.delegate = self
			let scroll = NSScrollView(frame: window.contentView!.bounds)
			scroll.documentView = outline
			window.contentView = scroll
			outline.reloadData()
			_ = outline.rowView(atRow: 0, makeIfNecessary: true)
		}

		func height() -> CGFloat {
			window.contentView?.layoutSubtreeIfNeeded()
			window.displayIfNeeded()
			outline.layoutSubtreeIfNeeded()
			return outline.rect(ofRow: 0).height
		}
	}
}

// MARK: - NSOutlineViewDataSource
extension ItemCellTests.OutlineFixture: NSOutlineViewDataSource {

	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		item == nil ? 1 : 0
	}

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		self.item
	}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		false
	}
}

// MARK: - NSOutlineViewDelegate
extension ItemCellTests.OutlineFixture: NSOutlineViewDelegate {

	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		cell
	}
}
