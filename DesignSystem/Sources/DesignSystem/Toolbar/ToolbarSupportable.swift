//
//  ToolbarSupportable.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 21.09.2025.
//

import UIKit

public protocol ToolbarSupportable: UIViewController {
	func displayToolbar(top: [UIBarButtonItem], bottom: [UIBarButtonItem])
}
