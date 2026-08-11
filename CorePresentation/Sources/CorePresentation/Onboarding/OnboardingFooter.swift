//
//  OnboardingFooter.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import SwiftUI

#if os(macOS)
struct OnboardingFooter {

	let state: OnboardingState

	var onBack: (() -> Void)?
	var secondaryAction: (() -> Void)?
	var primaryAction: (() -> Void)?
}

// MARK: - View
extension OnboardingFooter: View {

	var body: some View {
		HStack {

			if state.canBack {
				Button {
					onBack?()
				} label: {
					Text(OnboardingLocalization.backButtonTitle)
				}
				.controlSize(.large)
			}

			Spacer()
				if state.canNext {
					Button {
						secondaryAction?()
					} label: {
						Text(OnboardingLocalization.skipButtonTitle)
					}
					.controlSize(.large)
				}

				Button(action: {
					primaryAction?()
			}) {
				Text(
					state.canNext
						? OnboardingLocalization.nextButtonTitle
						: OnboardingLocalization.getStaredButtonTitle
				)
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
struct OnboardingFooter {

	let state: OnboardingState

	var secondaryAction: (() -> Void)?
	var primaryAction: (() -> Void)?
}

// MARK: - View
extension OnboardingFooter: View {

	var body: some View {
		VStack(spacing: 16) {
			Button {
				withAnimation {
					primaryAction?()
				}
			} label: {
				Text(
					state.canNext
						? OnboardingLocalization.nextButtonTitle
						: OnboardingLocalization.getStaredButtonTitle
				)
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)
			.buttonBorderShape(.capsule)
			.tint(.primary)
			.foregroundStyle(.background)
			.controlSize(.large)

				if state.canNext {
					Button {
						secondaryAction?()
					} label: {
						Text(OnboardingLocalization.skipButtonTitle)
							.frame(maxWidth: .infinity)
					}
					.buttonStyle(.borderless)
					.foregroundStyle(.primary)
					.controlSize(.large)
				}
			}
		}
	}
#endif

#Preview {
	OnboardingFooter(state: .preview(currentPage: 1))
}

#Preview {
	OnboardingFooter(state: .preview(currentPage: 0))
}

#Preview {
	OnboardingFooter(state: .preview(currentPage: 2))
}

// MARK: - Preview Helpers
private extension OnboardingState {

	static func preview(currentPage: Int) -> OnboardingState {
		var state = OnboardingState(features: .newFormat)
		state.currentPage = currentPage
		return state
	}
}
