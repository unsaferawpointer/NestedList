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

	static func map(icon: ItemIcon?, filled: Bool) -> SemanticImage? {
		guard let icon else {
			return nil
		}
		return map(icon: icon)
	}

	static func map(icon: ItemIcon) -> SemanticImage {
		return switch icon {
		case .document:		.textDoc()
		case .documents:	.docOnDoc()
		case .folder:		.folder()
		case .star:			.star()
		case .package:		.shippingbox()
		}
	}
}
