//
//  OnboardingFooter.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import SwiftUI

#if os(macOS)
struct OnboardingFooter: View {

	@Binding var state: OnboardingState

	var onBack: (() -> Void)?

	var secondaryAction: (() -> Void)?

	var primaryAction: (() -> Void)?

	var body: some View {
		HStack {

			if state.canBack() {
				Button {
					onBack?()
				} label: {
					Text("Back")
				}
				.controlSize(.large)
			}

			Spacer()

			// Кнопка Пропустить
			Button {
				secondaryAction?()
			} label: {
				Text("Skip")
			}
			.controlSize(.large)

			// Кнопка Продолжить
			Button(action: {
				primaryAction?()
			}) {
				Text( state.canNext() ? "Next" : "Get started")
					.frame(minWidth: 80)
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
		}
		.padding()
	}
}
#endif

#if os(iOS)
struct OnboardingFooter: View {

	@Binding var state: OnboardingState

	var secondaryAction: (() -> Void)?

	var primaryAction: (() -> Void)?

	var body: some View {
		VStack(spacing: 16) {
			Button {
				withAnimation {
					if state.canNext() {
						state.performPrimaryAction()
					} else {
						primaryAction?()
					}
				}
			} label: {
				Text(state.canNext() ? "Next" : "Get Started")
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
			Button {
				secondaryAction?()
			} label: {
				Text("Skip")
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderless)
			.controlSize(.large)
		}
	}
}
#endif

#Preview {
	OnboardingFooter(state: .constant(.init(pages: [.newFormat, .customization])))
}
