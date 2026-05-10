//
//  OnboardingView.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 30.04.2025.
//

import SwiftUI

public struct OnboardingView {

	@Environment(\.dismiss) private var dismiss

	@State private var isMovingForward = true

	@State var state: OnboardingState

	var onComplete: (() -> Void)?

	// MARK: - Initialization

	public init(pages: [Page], onComplete: (() -> Void)?) {
		self._state = State(initialValue: .init(pages: pages))
		self.onComplete = onComplete
	}

}

#if os(iOS)
extension OnboardingView: View {

	public var body: some View {
		VStack {
			TabView(selection: $state.currentPage) {
				ForEach(0..<state.features.count) { pageIndex in
					PageView(
						systemName: state.feature.icon,
						title: state.feature.title,
						description: state.feature.description
					)
					.tag(pageIndex)
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			OnboardingFooter(state: $state) {
				dismiss()
				onComplete?()
			} primaryAction: {
				dismiss()
				onComplete?()
			}
			.padding()
		}
		.ignoresSafeArea(edges: .all)
	}
}
#elseif os(macOS)

extension OnboardingView: View {

	public var body: some View {
		VStack(spacing: 0) {
			PageView(
				systemName: state.feature.icon,
				title: state.feature.title,
				description: state.feature.description
			)
			.id(state.id)
			.transition(
				.asymmetric(insertion: .opacity, removal: .opacity)
			)
			Spacer(minLength: 16)
			Divider()

			OnboardingFooter(state: $state) {
				withAnimation {
					state.back()
					isMovingForward = false
				}
			} secondaryAction: {
				onComplete?()
			} primaryAction: {
				withAnimation {
					if state.canNext() {
						state.performPrimaryAction()
						isMovingForward = true
					} else {
						onComplete?()
					}
				}
			}

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
	}
}
#endif

struct OnboardingState {

	var features: [Feature]

	var currentPage: Int

	init(pages: [Page]) {
		assert(!pages.isEmpty, "Pages list is empty")
		self.features = pages.flatMap { $0.features }
		self.currentPage = 0
	}
}

extension OnboardingState {

	var feature: Feature {
		return features[currentPage]
	}

	func canNext() -> Bool {
		currentPage < features.count - 1
	}

	func canBack() -> Bool {
		currentPage > 0
	}

	var pageTitle: String {
		return features[currentPage].title
	}

	var pageDescription: String {
		return features[currentPage].description
	}

	var id: String {
		return features[currentPage].id
	}

	mutating func performPrimaryAction() {
		if currentPage < features.count - 1 {
			withAnimation {
				currentPage += 1
			}
		}
	}

	mutating func back() {
		if currentPage > 0 {
			currentPage -= 1
		}
	}
}

#Preview {
	OnboardingView(pages: [.newFormat], onComplete: nil)
}

extension Page {

	static let newFormat = Page(
		id: "new_format",
		image: "document.badge.plus",
		iconColor: .primary,
		title: "New File Format",
		description: "We've upgraded your workflow",
		features:
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
	)
}
