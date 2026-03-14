//
//  ViewDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 16.02.2025.
//

@MainActor
public protocol ViewDelegate {
	func viewDidChange(state: ViewState)
}
