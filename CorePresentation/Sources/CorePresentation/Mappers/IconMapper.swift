//
//  IconMapper.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 29.09.2025.
//

import CoreModule
import DesignSystem

public final class IconMapper {

	public static func map(icon: IconName?, filled: Bool) -> SemanticImage? {
		guard let icon else {
			return nil
		}
		return map(icon: icon)
	}

	public static func map(icon: IconName) -> SemanticImage {
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

	public static func map(icon: SemanticImage?) -> IconName {
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
