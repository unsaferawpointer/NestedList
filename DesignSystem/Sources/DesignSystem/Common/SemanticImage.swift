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

public enum SemanticImage {

	case point
	case folder(filled: Bool = false)
	case textDoc(filled: Bool = false)
	case docOnDoc(filled: Bool = false)
	case shippingbox(filled: Bool = false)
	case star(filled: Bool = false)
}

// MARK: - Codable
extension SemanticImage: Codable { }

// MARK: - Hashable
extension SemanticImage: Hashable { }

// MARK: - Computed Properties
public extension SemanticImage {

	var title: String {
		switch self {
		case .point:
			"Point"
		case .folder:
			"Folder"
		case .textDoc:
			"Text Document"
		case .docOnDoc:
			"Documents"
		case .shippingbox:
			"Package"
		case .star:
			"Star"
		}
	}

	var tintColor: ColorToken {
		switch self {
		case .point:
			return .tertiary
		case .folder:
			return .cyan
		case .textDoc:
			return .gray
		case .docOnDoc:
			return .gray
		case .shippingbox:
			return .yellow
		case .star:
			return .yellow
		}
	}

	var systemName: String? {
		switch self {
		case .point:
			nil
		case let .folder(filled):
			filled ? "folder.fill" : "folder"
		case let .textDoc(filled):
			filled ? "doc.text.fill" : "doc.text"
		case let .docOnDoc(filled):
			filled ? "doc.on.doc.fill" : "doc.on.doc"
		case let .shippingbox(filled):
			filled ? "shippingbox.fill" : "shippingbox"
		case let .star(filled):
			filled ? "star.fill" : "star"
		}
	}
}

// MARK: - Helpers
private extension SemanticImage {

	var resource: ImageResource? {
		switch self {
		case .point:
			.point
		default:
			nil
		}
	}
}

#if canImport(AppKit)
// MARK: - Computed properties
public extension SemanticImage {

	var image: NSImage? {
		guard let systemName = self.systemName else {
			if let resource = self.resource {
				return NSImage(resource: resource)
			}
			return nil
		}
		return NSImage(systemSymbolName: systemName, accessibilityDescription: nil)
	}
}
#elseif canImport(UIKit)

import SwiftUI

// MARK: - Computed properties
public extension SemanticImage {

	var uiImage: UIImage {
		guard let systemName = self.systemName else {
			if let resource = self.resource {
				return UIImage(resource: resource)
			}
			fatalError()
		}
		return UIImage(systemName: systemName)!
	}
}
#endif
