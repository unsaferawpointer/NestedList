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
				ForEach(0..<state.pages.count) { pageIndex in
					VStack {
						OnboadringHeader(page: state.page)
						OnboardingBody(features: state.features)
							.padding(24)
					}
					.tag(pageIndex)
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .automatic))
			OnboardingFooter(state: $state) {
				dismiss()
				onComplete?()
			} primaryAction: {
				dismiss()
				onComplete?()
			}
			.padding()
		}
	}
}
#elseif os(macOS)

extension OnboardingView: View {

	public var body: some View {
		VStack(spacing: 0) {
			VStack(spacing: 20) {
				Spacer()
				OnboadringHeader(page: state.page)
					.padding(.vertical, 24)
				OnboardingBody(features: state.page.features)
					.padding(.horizontal)
					.padding(.bottom, 24)
			}
			.id(state.id)
			.transition(
				.asymmetric(
					insertion:
							.move(edge: isMovingForward ? .leading : .trailing)
							.combined(with: .opacity),
					removal:
							.move(edge: isMovingForward ? .leading : .trailing)
							.combined(with: .opacity)
				)
			)

			Divider()

			OnboardingFooter(state: $state) {
				withAnimation {
					isMovingForward = false
					state.back()
				}
			} secondaryAction: {
				onComplete?()
			} primaryAction: {
				withAnimation {
					if state.canNext() {
						isMovingForward = true
						state.performPrimaryAction()
					} else {
						onComplete?()
					}
				}
			}

		}
		.background(.ultraThickMaterial)
		.frame(
			minWidth: 640,
			idealWidth: 640,
			maxWidth: 760,
			minHeight: 480,
			idealHeight: 520,
			maxHeight: 560, alignment: .bottom
		)
	}
}
#endif

struct OnboardingState {

	var pages: [Page]

	var currentPage: Int

	init(pages: [Page] = [.newFormat, .customization]) {
		assert(!pages.isEmpty, "Pages list is empty")
		self.pages = pages
		self.currentPage = 0
	}
}

extension OnboardingState {

	var page: Page {
		return pages[currentPage]
	}

	func canNext() -> Bool {
		currentPage < pages.count - 1
	}

	func canBack() -> Bool {
		currentPage > 0
	}

	var pageTitle: String {
		return pages[currentPage].title
	}

	var pageDescription: String {
		return pages[currentPage].description
	}

	var features: [Feature] {
		return pages[currentPage].features
	}

	var id: String {
		return pages[currentPage].id
	}

	var image: String {
		return pages[currentPage].image
	}

	mutating func performPrimaryAction() {
		if currentPage < pages.count - 1 {
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
		title: "New File Format",
		description: "We've upgraded your workflow",
		features:
			[
				.init(
					icon: "arrow.down.document",
					title: "Easy Conversion",
					description: "Import legacy TXT files with one click"
				),
				.init(
					icon: "arrow.up.document",
					title: "Full Backward Compatibility",
					description: "Export back to TXT anytime"
				),
				.init(
					icon: "sparkles",
					title: "Exclusive Features",
					description: "Advanced functionality only available in the new format"
				)
			]
	)

	static let customization = Page(
		id: "customization",
		image: "slider.horizontal.2.square.on.square",
		title: "Redesigned Icons",
		description: "Customize App Appearance",
		features:
			[
				.init(
					icon: "arrow.down.document",
					title: "Unique Icons for Each Section",
					description: "Assign distinct icons to different categories"
				),
				.init(
					icon: "arrow.up.document",
					title: "Multiple Display Styles",
					description: "Choose the visual style that suits you best"
				),
				.init(
					icon: "sparkles",
					title: "Seamless Theme Adaptation",
					description: "Icons automatically adjust to light/dark mode"
				)
			]
	)
}
