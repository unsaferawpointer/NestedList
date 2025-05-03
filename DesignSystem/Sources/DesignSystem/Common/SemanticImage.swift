//
//  SemanticIcon.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 02.05.2025.
//

#if canImport(AppKit)

import AppKit

fileprivate typealias Image = NSImage

#elseif canImport(UIKit)

import UIKit

fileprivate typealias Image = UIImage

#endif

public enum SemanticImage: Int {

	case point = 0

	// MARK: - Objects
	case folder = 10
	case docText = 11
	case docOnDoc = 12
	case shippingbox = 13
	case star = 14
}

// MARK: - Codable
extension SemanticImage: Codable { }

// MARK: - Hashable
extension SemanticImage: Hashable { }

// MARK: - CaseIterable
extension SemanticImage: CaseIterable { }

// MARK: - Computed Properties
public extension SemanticImage {

	var title: String {
		switch self {
		case .point:
			"Point"
		case .folder:
			"Folder"
		case .docText:
			"Document"
		case .docOnDoc:
			"Documents"
		case .shippingbox:
			"Package"
		case .star:
			"Star"
		}
	}
}

#if canImport(AppKit)
// MARK: - Computed properties
public extension SemanticImage {

	var image: NSImage? {
		switch self {
		case .folder: NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil)
		case .docText: NSImage(systemSymbolName: "doc.text.fill", accessibilityDescription: nil)
		case .docOnDoc: NSImage(systemSymbolName: "doc.on.doc.fill", accessibilityDescription: nil)
		case .point: NSImage(resource: .point)
		case .shippingbox: NSImage(systemSymbolName: "shippingbox.fill", accessibilityDescription: nil)
		case .star: NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)
		}
	}
}
#elseif canImport(UIKit)
// MARK: - Computed properties
public extension SemanticImage {


	var image: UIImage? {
		switch self {
		case .folder: UIImage(systemName: "folder")
		case .docText: UIImage(systemName: "doc.text")
		case .docOnDoc: UIImage(systemName: "doc.on.doc")
		case .point: UIImage(resource: .point)
		case .shippingbox: UIImage(systemName: "shippingbox")
		case .star: UIImage(systemName: "star")
		}
	}
}
#endif
