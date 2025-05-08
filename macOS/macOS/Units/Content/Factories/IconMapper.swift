//
//  IconMapper.swift
//  Nested List
//
//  Created by Anton Cherkasov on 03.05.2025.
//

import CoreModule
import CoreSettings
import DesignSystem

final class IconMapper {

	static func map(icon: ItemIcon?, filled: Bool) -> SemanticImage? {
		guard let icon else {
			return nil
		}
		return switch icon {
		case .document:
			.textDoc(filled: filled)
		case .documents:
			.docOnDoc(filled: filled)
		case .folder:
			.folder(filled: filled)
		case .star:
			.star(filled: filled)
		case .package:
			.shippingbox(filled: filled)
		case .archivebox:
			.archivebox(filled: filled)
		case .stack:
			.squareStack(filled: filled)
		case .book:
			.book(filled: filled)
		case .squareGrid2x2:
			.squareGrid2x2(filled: filled)
		}
	}
}
