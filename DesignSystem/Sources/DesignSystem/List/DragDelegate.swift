//
//  DragDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 14.12.2024.
//

import Foundation

public protocol DragDelegate<ID>: AnyObject {

	associatedtype ID

	func write(ids: [ID], to pasteboard: PasteboardProtocol)
}
