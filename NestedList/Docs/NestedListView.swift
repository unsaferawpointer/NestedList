//
//  NestedListView.swift
//  NestedList
//
//  Created by Anton Cherkasov on 12.11.2024.
//

import SwiftUI

struct NestedListView: View {

	@Binding var document: NestedListDocument
	
	var body: some View {
		List(document.nodes, children: \.children) { node in
			Text(node.value.text)
				.listRowSeparator(.hidden)
		}
		.listStyle(.inset)
		.scrollIndicators(.hidden)
		.toolbar {
			Button("New Item", systemImage: "plus") {
				withAnimation {
					document.insert(to: nil)
				}
			}
		}
	}
}

#Preview {
	NestedListView(document: .constant(NestedListDocument()))
}
