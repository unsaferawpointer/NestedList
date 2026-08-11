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

#if canImport(AppKit)

import AppKit

// MARK: - Computed properties
public extension ControlState {

	var value: NSControl.StateValue {
		switch self {
		case .off:		.off
		case .on:		.on
		case .mixed:	.mixed
		}
	}
}

#endif
