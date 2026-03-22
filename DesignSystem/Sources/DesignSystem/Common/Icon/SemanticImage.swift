//
//	SemanticIcon.swift
//	CoreModule
//
//	Created by Anton Cherkasov on 02.05.2025.
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
	case moonStars
	case sparkles
	case flame
	case creditcard
	case gift
	case trash
	case receipt
	case terminal
	case calendar
	case clock
	case xmarkApp
	case checkmarkApp
	case xmarkDiamond
	case checkmarkDiamond
	case pc
	case location
	case bookmark
	case tag
	case squareOnSquare
	case insetDiamond
	case insetCircle
	case insetSquare
	case insetTriangle
	case personGroup
	case leaf
	case house
	case bell
	case conversation
	case envelope
	case gearshape
	case suitcase
	case key
	case airplane
	case carRear
	case film
	case photo
	case photoOnRectangle
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
			String(
				localized: "semantic-image-point",
				defaultValue: "Point",
				table: "Localizable",
				bundle: .module
			)
		case .folder:
			String(
				localized: "semantic-image-folder",
				defaultValue: "Folder",
				table: "Localizable",
				bundle: .module
			)
		case .textDoc:
			String(
				localized: "semantic-image-document",
				defaultValue: "Document",
				table: "Localizable",
				bundle: .module
			)
		case .docOnDoc:
			String(
				localized: "semantic-image-documents",
				defaultValue: "Documents",
				table: "Localizable",
				bundle: .module
			)
		case .shippingbox:
			String(
				localized: "semantic-image-package",
				defaultValue: "Package",
				table: "Localizable",
				bundle: .module
			)
		case .archivebox:
			String(
				localized: "semantic-image-archivebox",
				defaultValue: "Archive",
				table: "Localizable",
				bundle: .module
			)
		case .squareStack:
			String(
				localized: "semantic-image-stack",
				defaultValue: "Stack",
				table: "Localizable",
				bundle: .module
			)
		case .book:
			String(
				localized: "semantic-image-book",
				defaultValue: "Book",
				table: "Localizable",
				bundle: .module
			)
		case .squareGrid2x2:
			String(
				localized: "semantic-image-grid",
				defaultValue: "Grid",
				table: "Localizable",
				bundle: .module
			)
		case .star:
			String(
				localized: "semantic-image-star",
				defaultValue: "Star",
				table: "Localizable",
				bundle: .module
			)
		case .heart:
			String(
				localized: "semantic-image-heart",
				defaultValue: "Heart",
				table: "Localizable",
				bundle: .module
			)
		case .listStar:
			String(
				localized: "semantic-image-list-star",
				defaultValue: "List Star",
				table: "Localizable",
				bundle: .module
			)
		case .bolt:
			String(
				localized: "semantic-image-bolt",
				defaultValue: "Bolt",
				table: "Localizable",
				bundle: .module
			)
		case .person:
			String(
				localized: "semantic-image-person",
				defaultValue: "Person",
				table: "Localizable",
				bundle: .module
			)
		case .cloud:
			String(
				localized: "semantic-image-cloud",
				defaultValue: "Cloud",
				table: "Localizable",
				bundle: .module
			)
		case .sun:
			String(
				localized: "semantic-image-sun",
				defaultValue: "Sun",
				table: "Localizable",
				bundle: .module
			)
		case .moonStars:
			String(
				localized: "semantic-image-moon-stars",
				defaultValue: "Moon Stars",
				table: "Localizable",
				bundle: .module
			)
		case .sparkles:
			String(
				localized: "semantic-image-sparkles",
				defaultValue: "Sparkles",
				table: "Localizable",
				bundle: .module
			)
		case .flame:
			String(
				localized: "semantic-image-flame",
				defaultValue: "Flame",
				table: "Localizable",
				bundle: .module
			)
		case .creditcard:
			String(
				localized: "semantic-image-creditcard",
				defaultValue: "Credit Card",
				table: "Localizable",
				bundle: .module
			)
		case .gift:
			String(
				localized: "semantic-image-gift",
				defaultValue: "Gift",
				table: "Localizable",
				bundle: .module
			)
		case .trash:
			String(
				localized: "semantic-image-trash",
				defaultValue: "Trash",
				table: "Localizable",
				bundle: .module
			)
		case .receipt:
			String(
				localized: "semantic-image-receipt",
				defaultValue: "Receipt",
				table: "Localizable",
				bundle: .module
			)
		case .terminal:
			String(
				localized: "semantic-image-terminal",
				defaultValue: "Terminal",
				table: "Localizable",
				bundle: .module
			)
		case .calendar:
			String(
				localized: "semantic-image-calendar",
				defaultValue: "Calendar",
				table: "Localizable",
				bundle: .module
			)
		case .clock:
			String(
				localized: "semantic-image-clock",
				defaultValue: "Clock",
				table: "Localizable",
				bundle: .module
			)
		case .xmarkApp:
			String(
				localized: "semantic-image-xmark-app",
				defaultValue: "Xmark App",
				table: "Localizable",
				bundle: .module
			)
		case .checkmarkApp:
			String(
				localized: "semantic-image-checkmark-app",
				defaultValue: "Checkmark App",
				table: "Localizable",
				bundle: .module
			)
		case .xmarkDiamond:
			String(
				localized: "semantic-image-xmark-diamond",
				defaultValue: "Xmark Diamond",
				table: "Localizable",
				bundle: .module
			)
		case .checkmarkDiamond:
			String(
				localized: "semantic-image-checkmark-diamond",
				defaultValue: "Checkmark Diamond",
				table: "Localizable",
				bundle: .module
			)
		case .pc:
			String(
				localized: "semantic-image-pc",
				defaultValue: "PC",
				table: "Localizable",
				bundle: .module
			)
		case .location:
			String(
				localized: "semantic-image-location",
				defaultValue: "Location",
				table: "Localizable",
				bundle: .module
			)
		case .bookmark:
			String(
				localized: "semantic-image-bookmark",
				defaultValue: "Bookmark",
				table: "Localizable",
				bundle: .module
			)
		case .tag:
			String(
				localized: "semantic-image-tag",
				defaultValue: "Tag",
				table: "Localizable",
				bundle: .module
			)
		case .squareOnSquare:
			String(
				localized: "semantic-image-square-stack",
				defaultValue: "Square Stack",
				table: "Localizable",
				bundle: .module
			)
		case .insetDiamond:
			String(
				localized: "semantic-image-diamond",
				defaultValue: "Diamond",
				table: "Localizable",
				bundle: .module
			)
		case .insetCircle:
			String(
				localized: "semantic-image-circle",
				defaultValue: "Circle",
				table: "Localizable",
				bundle: .module
			)
		case .insetSquare:
			String(
				localized: "semantic-image-square",
				defaultValue: "Square",
				table: "Localizable",
				bundle: .module
			)
		case .insetTriangle:
			String(
				localized: "semantic-image-triangle",
				defaultValue: "Triangle",
				table: "Localizable",
				bundle: .module
			)
		case .personGroup:
			String(
				localized: "semantic-image-profiles",
				defaultValue: "Profiles",
				table: "Localizable",
				bundle: .module
			)
		case .leaf:
			String(
				localized: "semantic-image-leaf",
				defaultValue: "Leaf",
				table: "Localizable",
				bundle: .module
			)
		case .house:
			String(
				localized: "semantic-image-house",
				defaultValue: "House",
				table: "Localizable",
				bundle: .module
			)
		case .bell:
			String(
				localized: "semantic-image-bell",
				defaultValue: "Bell",
				table: "Localizable",
				bundle: .module
			)
		case .conversation:
			String(
				localized: "semantic-image-conversation",
				defaultValue: "Conversation",
				table: "Localizable",
				bundle: .module
			)
		case .envelope:
			String(
				localized: "semantic-image-envelope",
				defaultValue: "Envelope",
				table: "Localizable",
				bundle: .module
			)
		case .gearshape:
			String(
				localized: "semantic-image-settings",
				defaultValue: "Settings",
				table: "Localizable",
				bundle: .module
			)
		case .suitcase:
			String(
				localized: "semantic-image-suitcase",
				defaultValue: "Suitcase",
				table: "Localizable",
				bundle: .module
			)
		case .key:
			String(
				localized: "semantic-image-key",
				defaultValue: "Key",
				table: "Localizable",
				bundle: .module
			)
		case .airplane:
			String(
				localized: "semantic-image-airplane",
				defaultValue: "Airplane",
				table: "Localizable",
				bundle: .module
			)
		case .carRear:
			String(
				localized: "semantic-image-car",
				defaultValue: "Car",
				table: "Localizable",
				bundle: .module
			)
		case .film:
			String(
				localized: "semantic-image-film",
				defaultValue: "Film",
				table: "Localizable",
				bundle: .module
			)
		case .photo:
			String(
				localized: "semantic-image-photo",
				defaultValue: "Photo",
				table: "Localizable",
				bundle: .module
			)
		case .photoOnRectangle:
			String(
				localized: "semantic-image-gallery",
				defaultValue: "Gallery",
				table: "Localizable",
				bundle: .module
			)
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
		case .archivebox:
			"archivebox.fill"
		case .squareStack:
			"square.stack.3d.up.fill"
		case .book:
			"text.book.closed.fill"
		case .squareGrid2x2:
			"square.grid.2x2.fill"
		case .star:
			"star.fill"
		case .heart:
			"heart.fill"
		case .listStar:
			"text.badge.star"
		case .bolt:
			"bolt.fill"
		case .person:
			"person.text.rectangle.fill"
		case .cloud:
			"cloud.fill"
		case .sun:
			"sun.max.fill"
		case .moonStars:
			"moon.stars.fill"
		case .sparkles:
			"sparkles"
		case .flame:
			"flame.fill"
		case .creditcard:
			"creditcard.fill"
		case .gift:
			"gift.fill"
		case .trash:
			"trash.fill"
		case .receipt:
			"receipt.fill"
		case .terminal:
			"apple.terminal.on.rectangle.fill"
		case .calendar:
			"calendar"
		case .clock:
			"clock.fill"
		case .xmarkApp:
			"xmark.app.fill"
		case .checkmarkApp:
			"checkmark.app.fill"
		case .xmarkDiamond:
			"xmark.diamond.fill"
		case .checkmarkDiamond:
			"checkmark.diamond.fill"
		case .pc:
			"pc"
		case .location:
			"location.fill"
		case .bookmark:
			"bookmark.fill"
		case .tag:
			"tag.fill"
		case .squareOnSquare:
			"square.fill.on.square.fill"
		case .insetDiamond:
			"inset.filled.diamond"
		case .insetCircle:
			"inset.filled.circle"
		case .insetSquare:
			"inset.filled.square"
		case .insetTriangle:
			"inset.filled.triangle"
		case .personGroup:
			"person.crop.square.on.square.angled.fill"
		case .leaf:
			"leaf.fill"
		case .house:
			"house.fill"
		case .bell:
			"bell.fill"
		case .conversation:
			"bubble.left.and.text.bubble.right.fill"
		case .envelope:
			"envelope.fill"
		case .gearshape:
			"gearshape.fill"
		case .suitcase:
			"suitcase.fill"
		case .key:
			"key.fill"
		case .airplane:
			"airplane"
		case .carRear:
			"car.rear.fill"
		case .film:
			"film"
		case .photo:
			"photo.fill"
		case .photoOnRectangle:
			"photo.fill.on.rectangle.fill"
		}
	}

	func preferredAppearance(with token: ColorToken) -> IconAppearence? {
		switch self {
		case .listStar:
			.monochrome(token: token)
		case .xmarkApp:
			.monochrome(token: token)
		case .checkmarkApp:
			.monochrome(token: token)
		case .xmarkDiamond:
			.monochrome(token: token)
		case .checkmarkDiamond:
			.monochrome(token: token)
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
