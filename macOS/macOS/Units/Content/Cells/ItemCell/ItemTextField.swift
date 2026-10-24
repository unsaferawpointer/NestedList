import AppKit

final class ItemTextField: NSTextField {}

// MARK: - NSView sizing
extension ItemTextField {

	override var intrinsicContentSize: NSSize {
		let size = super.intrinsicContentSize
		guard bounds.width > 0, let cell else {
			return size
		}
		let availableBounds = NSRect(x: 0, y: 0, width: bounds.width, height: .greatestFiniteMagnitude)
		let height = ceil(cell.cellSize(forBounds: availableBounds).height)
		return NSSize(width: NSView.noIntrinsicMetric, height: max(size.height, height))
	}

	override func setFrameSize(_ newSize: NSSize) {
		let widthChanged = frame.width != newSize.width
		super.setFrameSize(newSize)
		if widthChanged {
			invalidateIntrinsicContentSize()
		}
	}
}

// MARK: - NSTextField editing
extension ItemTextField {

	override func textDidChange(_ notification: Notification) {
		super.textDidChange(notification)
		validateEditing()
		invalidateIntrinsicContentSize()
	}
}
