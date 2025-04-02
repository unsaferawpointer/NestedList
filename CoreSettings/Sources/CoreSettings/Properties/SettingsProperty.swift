//
//  SettingsProperty.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 11.03.2025.
//

import Foundation

protocol SettingsProperty: RawRepresentable {
	static var key: String { get }
}
