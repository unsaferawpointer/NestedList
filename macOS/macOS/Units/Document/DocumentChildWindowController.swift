//
//  DocumentChildWindowController.swift
//  macOS
//
//  Created by OpenAI on 13.06.2026.
//

import AppKit

final class DocumentChildWindowController: NSWindowController {

	weak var documentOwner: NSDocument?

	// MARK: - Initialization

	override init(window: NSWindow?) {
		super.init(window: window)
		self.window?.delegate = self
		self.shouldCloseDocument = false
	}

	@available(*, unavailable, message: "Use init(window:)")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func windowTitle(forDocumentDisplayName displayName: String) -> String {
		return contentViewController?.title ?? displayName
	}
}

// MARK: - NSWindowDelegate
extension DocumentChildWindowController: NSWindowDelegate {

	func windowWillClose(_ notification: Notification) {
		if let window {
			window.parent?.removeChildWindow(window)
		}
		documentOwner?.removeWindowController(self)
	}
}
