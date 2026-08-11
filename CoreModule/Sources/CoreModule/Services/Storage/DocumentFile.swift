//
//  DocumentFile.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation

struct DocumentFile<State: Codable>: Versioned, Codable {

	let version: Version

	var content: State
}
