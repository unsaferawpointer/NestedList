#if os(macOS)
import AppKit

public final class SpacerView: NSView {

	private let height: CGFloat

	public init(height: CGFloat) {
		self.height = height
		super.init(frame: .zero)
	}

	@available(*, unavailable, message: "Use init(height:)")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Layout
extension SpacerView {

	public override var intrinsicContentSize: NSSize {
		NSSize(width: NSView.noIntrinsicMetric, height: height)
	}
}
#endif
