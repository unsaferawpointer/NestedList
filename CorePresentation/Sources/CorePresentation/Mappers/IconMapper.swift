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
		return switch icon {
		case .document:			.textDoc(filled: filled)
		case .documents:		.docOnDoc(filled: filled)
		case .folder:			.folder(filled: filled)
		case .star:				.star(filled: filled)
		case .package:			.shippingbox(filled: filled)
		case .archivebox:		.archivebox(filled: filled)
		case .stack:			.squareStack(filled: filled)
		case .book:				.book(filled: filled)
		case .squareGrid2x2:	.squareGrid2x2(filled: filled)
		case .heart:			.heart(filled: filled)
		case .listStar:			.listStar(filled: filled)
		case .bolt:				.bolt(filled: filled)
		case .person:			.person(filled: filled)
		case .cloud:			.cloud(filled: filled)
		case .sun:				.sun(filled: filled)
		case .sparkles:			.sparkles(filled: filled)
		case .flame:			.flame(filled: filled)
		case .creditcard:		.creditcard(filled: filled)
		case .giftcard:			.giftcard(filled: filled)
		case .banknote:			.banknote(filled: filled)
		}
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
		case .person:			.person()
		case .cloud:			.cloud()
		case .sun:				.sun()
		case .sparkles:			.sparkles()
		case .flame:			.flame()
		case .creditcard:		.creditcard()
		case .giftcard:			.giftcard()
		case .banknote:			.banknote()
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
		case .person:			.person
		case .cloud:			.cloud
		case .sun:				.sun
		case .sparkles:			.sparkles
		case .flame:			.flame
		case .creditcard:		.creditcard
		case .giftcard:			.giftcard
		case .banknote:			.banknote
		default:				.document
		}
	}
}
