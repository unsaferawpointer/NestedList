//
//  ContentView.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 14.09.2025.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: MultiplatformDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(MultiplatformDocument()))
}
