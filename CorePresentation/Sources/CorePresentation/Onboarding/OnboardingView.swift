//
//  OnboardingView.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 30.04.2025.
//

import SwiftUI

public struct OnboardingView {

	@Environment(\.dismiss) private var dismiss

	@State private var viewModel: OnboardingViewModel

	private var onComplete: (@MainActor () -> Void)?

	// MARK: - Initialization

	public init(
		features: [Feature],
		analytics: any OnboardingAnalyticsServiceProtocol = OnboardingAnalyticsService(),
		onComplete: (@MainActor () -> Void)?
	) {
		self._viewModel = State(
			initialValue: .init(features: features, analytics: analytics)
		)
		self.onComplete = onComplete
	}
}

#if os(iOS)
extension OnboardingView: View {

	public var body: some View {
		@Bindable var viewModel = viewModel

		VStack {
			TabView(selection: $viewModel.currentPage) {
				ForEach(viewModel.pageIndices, id: \.self) { pageIndex in
					let feature = viewModel.features[pageIndex]
					PageView(
						systemName: feature.icon,
						title: feature.title,
						description: feature.description
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
		.ignoresSafeArea(edges: .all)
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

extension OnboardingView: View {

	public var body: some View {
		VStack(spacing: 0) {
			PageView(
				systemName: viewModel.feature.icon,
				title: viewModel.feature.title,
				description: viewModel.feature.description
			)
			.id(viewModel.id)
			.transition(
				.asymmetric(insertion: .opacity, removal: .opacity)
			)
			Spacer(minLength: 16)
			Divider()

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
			idealWidth: 720,
			maxWidth: 820,
			minHeight: 560,
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
	OnboardingView(features: .newFormat, onComplete: nil)
}

extension [Feature] {

	static var newFormat: [Feature] {
		[
			.init(
				icon: "arrow.down.document",
				iconColor: .primary,
				title: "Easy Conversion",
				description: "Import legacy TXT files with one click"
			),
			.init(
				icon: "arrow.up.document",
				iconColor: .primary,
				title: "Full Backward Compatibility",
				description: "Export back to TXT anytime"
			),
			.init(
				icon: "sparkles",
				iconColor: .primary,
				title: "Exclusive Features",
				description: "Advanced functionality only available in the new format"
			)
		]
	}
}
