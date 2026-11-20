//
//  OnboardingView.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 30.04.2025.
//

import SwiftUI

@MainActor public struct OnboardingView {

	@Environment(\.dismiss) private var dismiss

	@State private var viewModel: OnboardingViewModel

	private var onComplete: (@MainActor () -> Void)?

	// MARK: - Initialization

	public init(
		features: [Onboarding.Feature],
		analytics: any ConcreteAnalyticsServiceProtocol<OnboardingAnalyticsEvent> = ConcreteAnalyticsService<OnboardingAnalyticsEvent>(),
		onComplete: (@MainActor () -> Void)?
	) {
		self._viewModel = State(
			initialValue: .init(features: features, analytics: analytics)
		)
		self.onComplete = onComplete
	}
}

#if os(iOS)
// MARK: - View
extension OnboardingView: View {

	public var body: some View {
		@Bindable var viewModel = viewModel

		VStack {
			TabView(selection: $viewModel.currentPage) {
				ForEach(viewModel.pageIndices, id: \.self) { pageIndex in
					let feature = viewModel.features[pageIndex]
					OnboardingPage(
						title: feature.title,
						subtitle: feature.subtitle,
						scenario: feature.scenario,
						isActive: viewModel.currentPage == pageIndex && !viewModel.isCompleted
					)
					.tag(pageIndex)
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			OnboardingFooter(
				state: viewModel.state,
				secondaryAction: viewModel.skip,
				primaryAction: viewModel.primaryAction
			)
			.padding()
		}
		.onAppear {
			viewModel.show()
		}
		.onChange(of: viewModel.isCompleted) { _, isCompleted in
			guard isCompleted else {
				return
			}
			handleCompletion()
		}
	}
}
#elseif os(macOS)

// MARK: - View
extension OnboardingView: View {

	public var body: some View {
		VStack(spacing: 0) {
			OnboardingPage(
				title: viewModel.feature.title,
				subtitle: viewModel.feature.subtitle,
				scenario: viewModel.feature.scenario,
				isActive: !viewModel.isCompleted
			)
			.id(viewModel.id)
			.transition(
				.asymmetric(insertion: .opacity, removal: .opacity)
			)

			OnboardingFooter(
				state: viewModel.state,
				onBack: viewModel.back,
				secondaryAction: viewModel.skip,
				primaryAction: viewModel.primaryAction
			)
		}
		.background(.ultraThickMaterial)
		.frame(
			minWidth: 640,
			idealWidth: 680,
			maxWidth: 820,
			minHeight: 560,
			idealHeight: 600,
			maxHeight: 640,
			alignment: .bottom
		)
		.onAppear {
			viewModel.show()
		}
		.onChange(of: viewModel.isCompleted) { _, isCompleted in
			guard isCompleted else {
				return
			}
			handleCompletion()
		}
	}
}
#endif

// MARK: - Private methods
private extension OnboardingView {

	@MainActor func handleCompletion() {
		#if os(iOS)
		dismiss()
		#endif
		onComplete?()
	}
}

#Preview {
	OnboardingView(features: OnboardingFactory.build(), onComplete: nil)
		.environment(\.scenePhase, .active)
}
