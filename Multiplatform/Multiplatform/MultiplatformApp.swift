//
//  MultiplatformApp.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 05.09.2025.
//

import SwiftUI

@main
struct MultiplatformApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MultiplatformDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
