//
//  ControlState.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.04.2025.
//

public enum ControlState {
	case off
	case on
	case mixed
}

#if canImport(UIKit)

import UIKit

// MARK: - Computed properties
public extension ControlState {

	var value: UIMenuElement.State {
		switch self {
		case .off:		.off
		case .on:		.on
		case .mixed:	.mixed
		}
	}
}

#endif
