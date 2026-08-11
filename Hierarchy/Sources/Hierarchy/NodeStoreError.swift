//
//  NodeStoreError.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 15.06.2026.
//

import Foundation

public enum NodeStoreError: Error {
	case duplicateNode
	case invalidDestinationIndex
	case missingNode
}
