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
	case folder
	case textDoc
	case docOnDoc
	case shippingbox
	case archivebox
	case squareStack
	case book
	case squareGrid2x2
	case star
	case heart
	case listStar
	case bolt
	case person
	case cloud
	case sun
	case sparkles
	case flame
	case creditcard
	case giftcard
	case banknote
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
		case .folder:
			"folder.fill"
		case .textDoc:
			"doc.text.fill"
		case .docOnDoc:
			"doc.on.doc.fill"
		case .shippingbox:
			"shippingbox.fill"
		case .star:
			"star.fill"
		case .archivebox:
			"archivebox.fill"
		case .squareStack:
			"square.stack.3d.up.fill"
		case .book:
			"book.closed.fill"
		case .squareGrid2x2:
			"square.grid.2x2.fill"
		case .heart:
			"heart.fill"
		case .listStar:
			"text.badge.star"
		case .bolt:
			"bolt.fill"
		case .person:
			"person.fill"
		case .cloud:
			"cloud.fill"
		case .sun:
			"sun.max.fill"
		case .sparkles:
			"sparkles"
		case .flame:
			"flame.fill"
		case .creditcard:
			"creditcard.fill"
		case .giftcard:
			"giftcard.fill"
		case .banknote:
			"banknote.fill"
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
