//
//  ViewState.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 16.02.2025.
//

public enum ViewState {
	case willAppear
	case didLoad
	case didAppear
	case willDisappear
	case didDisappear
}

// MARK: - Equatable
extension ViewState: Equatable { }
