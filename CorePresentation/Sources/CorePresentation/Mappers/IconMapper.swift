//
//  IconMapper.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 29.09.2025.
//

import CoreModule
import DesignSystem

public final class IconMapper {

	public static func map(icon: IconName?, filled _: Bool) -> SemanticImage? {
		guard let icon else {
			return nil
		}
		return switch icon {
		case .document:			.textDoc
		case .documents:		.docOnDoc
		case .folder:			.folder
		case .star:				.star
		case .package:			.shippingbox
		case .archivebox:		.archivebox
		case .stack:			.squareStack
		case .book:				.book
		case .squareGrid2x2:	.squareGrid2x2
		case .heart:			.heart
		case .listStar:			.listStar
		case .bolt:				.bolt
		case .person:			.person
		case .cloud:			.cloud
		case .sun:				.sun
		case .moonStars:			.moonStars
		case .sparkles:			.sparkles
		case .flame:			.flame
		case .creditcard:		.creditcard
		case .gift:			.gift
		case .trash:			.trash
		case .receipt:			.receipt
		case .terminal:			.terminal
		case .calendar:			.calendar
		case .clock:			.clock
		case .xmarkApp:			.xmarkApp
		case .checkmarkApp:		.checkmarkApp
		case .xmarkDiamond:		.xmarkDiamond
		case .checkmarkDiamond:	.checkmarkDiamond
		case .pc:				.pc
		case .location:			.location
		case .bookmark:			.bookmark
		case .tag:				.tag
		case .squareOnSquare:	.squareOnSquare
		case .insetDiamond:		.insetDiamond
		case .bell:				.bell
		case .conversation:		.conversation
		case .envelope:			.envelope
		case .gearshape:		.gearshape
		case .suitcase:			.suitcase
		case .key:				.key
		case .airplane:			.airplane
		case .carRear:			.carRear
		case .film:				.film
		case .photo:			.photo
		case .photoOnRectangle:	.photoOnRectangle
		case .insetCircle:		.insetCircle
		case .insetSquare:		.insetSquare
		case .insetTriangle:		.insetTriangle
		case .personCropSquareOnSquareAngled: .personGroup
		case .leaf:				.leaf
		case .house:			.house
		}
	}

	public static func map(icon: IconName) -> SemanticImage {
		return switch icon {
		case .document:			.textDoc
		case .documents:		.docOnDoc
		case .folder:			.folder
		case .star:				.star
		case .package:			.shippingbox
		case .archivebox:		.archivebox
		case .stack:			.squareStack
		case .book:				.book
		case .squareGrid2x2:	.squareGrid2x2
		case .heart:			.heart
		case .listStar:			.listStar
		case .bolt:				.bolt
		case .person:			.person
		case .cloud:			.cloud
		case .sun:				.sun
		case .moonStars:			.moonStars
		case .sparkles:			.sparkles
		case .flame:			.flame
		case .creditcard:		.creditcard
		case .gift:			.gift
		case .trash:			.trash
		case .receipt:			.receipt
		case .terminal:			.terminal
		case .calendar:			.calendar
		case .clock:			.clock
		case .xmarkApp:			.xmarkApp
		case .checkmarkApp:		.checkmarkApp
		case .xmarkDiamond:		.xmarkDiamond
		case .checkmarkDiamond:	.checkmarkDiamond
		case .pc:				.pc
		case .location:			.location
		case .bookmark:			.bookmark
		case .tag:				.tag
		case .squareOnSquare:	.squareOnSquare
		case .insetDiamond:		.insetDiamond
		case .bell:				.bell
		case .conversation:		.conversation
		case .envelope:			.envelope
		case .gearshape:		.gearshape
		case .suitcase:			.suitcase
		case .key:				.key
		case .airplane:			.airplane
		case .carRear:			.carRear
		case .film:				.film
		case .photo:			.photo
		case .photoOnRectangle:	.photoOnRectangle
		case .insetCircle:		.insetCircle
		case .insetSquare:		.insetSquare
		case .insetTriangle:		.insetTriangle
		case .personCropSquareOnSquareAngled: .personGroup
		case .leaf:				.leaf
		case .house:			.house
		}
	}

	public static func map(icon: SemanticImage?) -> IconName? {
		guard let icon else {
			return nil
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
		case .moonStars:		.moonStars
		case .sparkles:			.sparkles
		case .flame:			.flame
		case .creditcard:		.creditcard
		case .gift:				.gift
		case .trash:			.trash
		case .receipt:			.receipt
		case .terminal:			.terminal
		case .calendar:			.calendar
		case .clock:			.clock
		case .xmarkApp:			.xmarkApp
		case .checkmarkApp:		.checkmarkApp
		case .xmarkDiamond:		.xmarkDiamond
		case .checkmarkDiamond:	.checkmarkDiamond
		case .pc:				.pc
		case .location:			.location
		case .bookmark:			.bookmark
		case .tag:				.tag
		case .squareOnSquare:	.squareOnSquare
		case .insetDiamond:		.insetDiamond
		case .bell:				.bell
		case .conversation:		.conversation
		case .envelope:			.envelope
		case .gearshape:		.gearshape
		case .suitcase:			.suitcase
		case .key:				.key
		case .airplane:			.airplane
		case .carRear:			.carRear
		case .film:				.film
		case .photo:			.photo
		case .photoOnRectangle:	.photoOnRectangle
		case .insetCircle:		.insetCircle
		case .insetSquare:		.insetSquare
		case .insetTriangle:		.insetTriangle
		case .personGroup: .personCropSquareOnSquareAngled
		case .leaf:				.leaf
		case .house:			.house
		default:				.document
		}
	}
}
