import AppKit
import DesignSystem
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
		let model = ItemModel(
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
		let fixture = LayoutFixture(model: model)

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
}

// MARK: - Nested data structs
private extension ItemCellTests {

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

		init(model: ItemModel) {
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

		func layout(subtitle: String?) -> Layout {
			cell.model.value.subtitle = subtitle
			let height = row.fittingSize.height
			cachedHeight.constant = height
			row.setFrameSize(NSSize(width: 400, height: height))
			row.layoutSubtreeIfNeeded()
			return Layout(
				height: height,
				titleFrame: cell.titleTextfield.convert(cell.titleTextfield.bounds, to: row),
				subtitleFrame: cell.subtitleTextfield.convert(cell.subtitleTextfield.bounds, to: row)
			)
		}
	}
}
