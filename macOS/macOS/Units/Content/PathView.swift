//
//  PathView.swift
//  macOS
//
//  Created by Anton Cherkasov on 15.10.2026.
//

import Cocoa

final class PathView: NSVisualEffectView {

	// MARK: - UI

	private lazy var pathControl: NSPathControl = {
		let view = NSPathControl()
		view.pathStyle = .standard
		view.controlSize = .mini
		view.focusRingType = .none
		view.target = self
		view.action = #selector(pathControlDidClick(_:))
		return view
	}()

	// MARK: - State

	var didSelectItem: ((UUID?) -> Void)?

	private var items: [PathItem] = []

	// MARK: - Initialization

	init() {
		super.init(frame: .zero)
		material = .headerView
		blendingMode = .withinWindow
		state = .active
		isHidden = true
		configureConstraints()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Public Interface
extension PathView {

	func display(_ items: [PathItem]) {
		self.items = items
		pathControl.pathItems = items.map { item in
			let pathControlItem = NSPathControlItem()
			pathControlItem.title = item.text
			return pathControlItem
		}
		isHidden = items.isEmpty
	}
}

// MARK: - Actions
private extension PathView {

	@objc
	func pathControlDidClick(_ sender: NSPathControl) {
		guard
			let item = sender.clickedPathItem,
			let index = sender.pathItems.firstIndex(where: { $0 === item }),
			items.indices.contains(index)
		else {
			return
		}
		didSelectItem?(items[index].id)
	}
}

// MARK: - Private
private extension PathView {

	func configureConstraints() {
		[pathControl].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		pathControl.setContentHuggingPriority(.required, for: .vertical)
		pathControl.setContentCompressionResistancePriority(.required, for: .vertical)
		pathControl.setContentHuggingPriority(.defaultLow, for: .horizontal)
		pathControl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		NSLayoutConstraint.activate(
			[
				pathControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
				pathControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
				pathControl.topAnchor.constraint(equalTo: topAnchor, constant: 6),
				pathControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
			]
		)
	}
}
