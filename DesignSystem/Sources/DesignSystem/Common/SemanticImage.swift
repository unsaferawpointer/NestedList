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
	case cut = 1
	case copy = 2
	case paste = 3
	case pencil = 4
	case plus = 5
	case trash = 6
	case checkmark = 7
	case settings = 8
	case ellipsisCircle = 9
	case reorder = 101
	case checkmarkCircle = 102

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
		case .cut:
			"Cut"
		case .copy:
			"Copy"
		case .paste:
			"Paste"
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
		case .pencil:
			"Pencil"
		case .plus:
			"Plus"
		case .trash:
			"Trash"
		case .checkmark:
			"Checkmark"
		case .settings:
			"Settings"
		case .ellipsisCircle:
			"Ellipsis"
		case .reorder:
			"Reorder"
		case .checkmarkCircle:
			"Checkmark Circle"
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
		default:
			nil
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
		case .cut: UIImage(systemName: "doc.on.doc")
		case .copy: UIImage(systemName: "scissors")
		case .paste: UIImage(systemName: "doc.on.clipboard")
		case .pencil: UIImage(systemName: "pencil")
		case .plus: UIImage(systemName: "plus")
		case .trash: UIImage(systemName: "trash")
		case .checkmark: UIImage(systemName: "checkmark")
		case .settings: UIImage(systemName: "slider.horizontal.2.square")
		case .ellipsisCircle: UIImage(systemName: "ellipsis.circle")
		case .reorder: UIImage(systemName: "line.3.horizontal")
		case .checkmarkCircle: UIImage(systemName: "checkmark.circle")
		}

	}
}
#endif
