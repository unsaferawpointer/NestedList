//
//  IconMapper.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.05.2025.
//

import CoreModule
import CoreSettings
import DesignSystem

final class IconMapper {

	static func map(icon: IconName?, filled: Bool) -> SemanticImage? {
		guard let icon else {
			return nil
		}
		return map(icon: icon)
	}

	static func map(icon: IconName) -> SemanticImage {
		return switch icon {
		case .document:			.textDoc()
		case .documents:		.docOnDoc()
		case .folder:			.folder()
		case .star:				.star()
		case .package:			.shippingbox()
		case .archivebox:		.archivebox()
		case .stack:			.squareStack()
		case .book:				.book()
		case .squareGrid2x2:	.squareGrid2x2()
		case .heart:			.heart()
		case .listStar:			.listStar()
		case .bolt:				.bolt()
		}
	}

	static func map(icon: SemanticImage?) -> IconName {
		guard let icon else {
			return .document
		}
		return switch icon {
		case .textDoc:			.document
		case .docOnDoc:			.documents
		case .folder:			.folder
		case .star:				.star
		case .shippingbox:		.package
		case .archivebox:		.archivebox
		case .squareStack:		.stack
		case .book:				.book
		case .squareGrid2x2:	.squareGrid2x2
		case .heart:			.heart
		case .listStar:			.listStar
		case .bolt:				.bolt
		default:				.document
		}
	}
}
