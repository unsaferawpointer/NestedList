//
//  NestedListApp.swift
//  NestedList
//
//  Created by Anton Cherkasov on 12.11.2024.
//

import SwiftUI

@main
struct NestedListApp: App {

	var body: some Scene {
		DocumentGroup(newDocument: NestedListDocument()) { file in
			NestedListView(document: file.$document)
		}
	}
}
