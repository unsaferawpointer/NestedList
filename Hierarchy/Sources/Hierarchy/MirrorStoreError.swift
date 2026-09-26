//
//  MirrorStoreError.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 24.09.2026.
//

import Foundation

public enum MirrorStoreError: Error {
	case duplicateIdentifier
	case missingReference
	case referenceIsMirror
	case referenceCycle
	case mirrorHasChildren
	case missingDestination
	case invalidDestinationIndex
	case movingIntoDescendant
}
