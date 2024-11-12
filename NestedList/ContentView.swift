//
//  ContentView.swift
//  NestedList
//
//  Created by Anton Cherkasov on 12.11.2024.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: NestedListDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(NestedListDocument()))
}
