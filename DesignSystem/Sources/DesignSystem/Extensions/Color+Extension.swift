//
//  Color+Extension.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 11.06.2026.
//

import SwiftUI

#if canImport(AppKit)
import AppKit

extension Color {

	static let tertiarySystemFill = Color(nsColor: .tertiarySystemFill)
}
#elseif canImport(UIKit)
import UIKit

extension Color {

	static let tertiarySystemFill = Color(uiColor: .tertiarySystemFill)
}
#endif
