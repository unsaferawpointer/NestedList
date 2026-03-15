//
//  SemanticIcon.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 02.05.2025.
//

import SwiftUI

#if canImport(AppKit)

import AppKit

fileprivate typealias Image = NSImage

#elseif canImport(UIKit)

import UIKit

fileprivate typealias Image = UIImage

#endif

public enum SemanticImage {

	case point
	case circleSlash
	case folder(filled: Bool = true)
	case textDoc(filled: Bool = true)
	case docOnDoc(filled: Bool = true)
	case shippingbox(filled: Bool = true)
	case archivebox(filled: Bool = true)
	case squareStack(filled: Bool = true)
	case book(filled: Bool = true)
	case squareGrid2x2(filled: Bool = true)
	case star(filled: Bool = true)
	case heart(filled: Bool = true)
	case listStar(filled: Bool = false)
	case bolt(filled: Bool = true)
	case person(filled: Bool = true)
	case cloud(filled: Bool = true)
	case sun(filled: Bool = true)
	case sparkles(filled: Bool = true)
	case flame(filled: Bool = true)
	case creditcard(filled: Bool = true)
	case giftcard(filled: Bool = true)
	case banknote(filled: Bool = true)
}

// MARK: - Codable
extension SemanticImage: Codable { }

// MARK: - Hashable
extension SemanticImage: Hashable { }

// MARK: - Computed Properties
public extension SemanticImage {

	var title: String {
		switch self {
		case .circleSlash:
			""
		case .point:
			String(localized: "semantic-image-point", table: "Localizable", bundle: .module)
		case .folder:
			String(localized: "semantic-image-folder", table: "Localizable", bundle: .module)
		case .textDoc:
			String(localized: "semantic-image-document", table: "Localizable", bundle: .module)
		case .docOnDoc:
			String(localized: "semantic-image-documents", table: "Localizable", bundle: .module)
		case .shippingbox:
			String(localized: "semantic-image-package", table: "Localizable", bundle: .module)
		case .star:
			String(localized: "semantic-image-star", table: "Localizable", bundle: .module)
		case .archivebox:
			String(localized: "semantic-image-archivebox", table: "Localizable", bundle: .module)
		case .squareStack:
			String(localized: "semantic-image-stack", table: "Localizable", bundle: .module)
		case .book:
			String(localized: "semantic-image-book", table: "Localizable", bundle: .module)
		case .squareGrid2x2:
			String(localized: "semantic-image-grid", table: "Localizable", bundle: .module)
		case .heart:
			String(localized: "semantic-image-heart", table: "Localizable", bundle: .module)
		case .listStar:
			String(localized: "semantic-image-list-star", table: "Localizable", bundle: .module)
		case .bolt:
			String(localized: "semantic-image-bolt", table: "Localizable", bundle: .module)
			case .person:
				String(localized: "semantic-image-person", table: "Localizable", bundle: .module)
			case .cloud:
				String(localized: "semantic-image-cloud", table: "Localizable", bundle: .module)
			case .sun:
				String(localized: "semantic-image-sun", table: "Localizable", bundle: .module)
			case .sparkles:
				String(localized: "semantic-image-sparkles", table: "Localizable", bundle: .module)
			case .flame:
				String(localized: "semantic-image-flame", table: "Localizable", bundle: .module)
			case .creditcard:
				String(localized: "semantic-image-creditcard", table: "Localizable", bundle: .module)
			case .giftcard:
				String(localized: "semantic-image-giftcard", table: "Localizable", bundle: .module)
			case .banknote:
				String(localized: "semantic-image-banknote", table: "Localizable", bundle: .module)
			}
		}

	var systemName: String? {
		switch self {
		case .circleSlash:
			"circle.slash"
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
		case let .archivebox(filled):
			filled ? "archivebox.fill" : "archivebox"
		case let .squareStack(filled):
			filled ? "square.stack.3d.up.fill" : "square.stack.3d.up"
		case let .book(filled):
			filled ? "book.closed.fill" : "book.closed"
		case let .squareGrid2x2(filled):
			filled ? "square.grid.2x2.fill" : "square.grid.2x2"
		case let .heart(filled):
			filled ? "heart.fill" : "heart"
		case let .listStar(filled):
			filled ? nil : "text.badge.star"
		case let .bolt(filled):
			filled ? "bolt.fill" : "bolt"
			case let .person(filled):
				filled ? "person.fill" : "person"
			case let .cloud(filled):
				filled ? "cloud.fill" : "cloud"
			case let .sun(filled):
				filled ? "sun.max.fill" : "sun.max"
			case .sparkles:
				"sparkles"
			case let .flame(filled):
				filled ? "flame.fill" : "flame"
			case let .creditcard(filled):
				filled ? "creditcard.fill" : "creditcard"
			case let .giftcard(filled):
				filled ? "giftcard.fill" : "giftcard"
			case let .banknote(filled):
				filled ? "banknote.fill" : "banknote"
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

public extension SemanticImage {

	var image: SwiftUI.Image? {
		guard let systemName = self.systemName else {
			if let resource = self.resource {
				return SwiftUI.Image(resource)
			}
			return nil
		}
		return SwiftUI.Image(systemName: systemName)
	}
}

#if canImport(AppKit)
// MARK: - Computed properties
public extension SemanticImage {

	var nsImage: NSImage? {
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
