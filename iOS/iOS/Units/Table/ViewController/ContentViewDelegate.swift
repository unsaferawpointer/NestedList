//
//  ContentViewDelegate.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.02.2025.
//

import Foundation
import CoreModule
import DesignSystem

@MainActor protocol ContentViewDelegate<ID>: ListDelegate,
												 DropDelegate,
												 ViewDelegate,
												 ContentMenuDelegate,
												 ContentToolbarDelegate {
	func menuConfiguration(for ids: [ID]) -> ContentMenuConfiguration
}
