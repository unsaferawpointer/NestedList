//
//  UUID+Extension.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 20.07.2026.
//

import Foundation
import Hierarchy

extension UUID: @retroactive RandomizableIdentifier {

	public static func random() -> UUID {
		UUID()
	}
}
