//
//  ItemPicker.swift
//  CorePresentation
//

import CoreModule
import DesignSystem
import SwiftUI

#if os(macOS)
import AppKit
#endif

@MainActor public struct ItemPicker {

	private let model: ItemPickerViewModel
	private let emptyState: EmptyState
	private let subtitle: String?
	@State private var isSearchPresented = false

	// MARK: - Initialization

	public init(
		storage: DocumentStorage<DocumentContent>,
		configuration: Configuration,
		analytics: any ConcreteAnalyticsServiceProtocol<ItemPickerAnalyticsEvent> = ConcreteAnalyticsService<ItemPickerAnalyticsEvent>(),
		completionHandler: @escaping @MainActor (UUID?, Bool) -> Void
	) {
		self.emptyState = configuration.emptyState
		self.subtitle = configuration.subtitle
		self.model = ItemPickerViewModel(
			storage: storage,
			title: configuration.title,
			allowedIDs: configuration.allowedIDs,
			analytics: analytics,
			action: completionHandler
		)
	}
}

// MARK: - View - iOS
#if os(iOS)
extension ItemPicker: View {

	public var body: some View {
		@Bindable var model = model

		NavigationStack {
			List {
				ForEach(model.filteredItems) { item in
					Button {
						model.select(item)
					} label: {
						ItemRow(item: item)
							.contentShape(Rectangle())
					}
					.buttonStyle(.plain)
				}
			}
			.listStyle(.insetGrouped)
			.overlay {
				emptyStateView
			}
			.searchable(text: $model.searchText)
			.navigationTitle(model.title)
			.itemPickerSubtitle(subtitle)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						model.cancel()
					} label: {
						Image(systemName: "xmark")
					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.onAppear {
				model.show()
			}
		}
	}
}
#endif

// MARK: - View - macOS
#if os(macOS)
extension ItemPicker: View {

	public var body: some View {
		@Bindable var model = model

		NavigationStack {
			List {
				ForEach(model.filteredItems) { item in
					Button {
						model.select(item)
					} label: {
						ItemRow(item: item)
							.contentShape(Rectangle())
					}
					.buttonStyle(.plain)
				}
				.listRowSeparator(.hidden)
			}
			.listStyle(.inset)
			.scrollIndicators(.hidden)
			.overlay {
				emptyStateView
			}
			.searchable(
				text: $model.searchText,
				isPresented: $isSearchPresented,
				placement: .toolbar
			)
			.navigationTitle(model.title)
			.itemPickerSubtitle(subtitle)
			.toolbarBackground(.hidden, for: .windowToolbar)
			.safeAreaInset(edge: .bottom) {
				VStack {
					Divider()
					HStack {
						Spacer()
						Button("Cancel", role: .cancel) {
							model.cancel()
						}
					}
					.padding()
				}
				.background(Color(nsColor: .windowBackgroundColor))
			}
			.onAppear {
				model.show()
			}
		}
		.frame(minWidth: 640, minHeight: 480)
	}
}
#endif

// MARK: - Private Views
private extension ItemPicker {

	@ViewBuilder var emptyStateView: some View {
		if model.items.isEmpty {
			ContentUnavailableView {
				Label(emptyState.title, systemImage: "list.bullet")
			} description: {
				if let message = emptyState.message {
					Text(message)
				}
			}
		} else if model.filteredItems.isEmpty {
			ContentUnavailableView.search(text: model.searchText)
		}
	}

	struct ItemRow {

		let item: ItemPickerItem
	}
}

// MARK: - View
extension ItemPicker.ItemRow: View {

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(item.title)
				.font(.body)
			if !item.path.isEmpty {
				Text(item.path)
					.font(.caption)
					.foregroundStyle(.secondary)
					.fixedSize(horizontal: false, vertical: true)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.accessibilityElement(children: .combine)
	}
}

// MARK: - Private View Modifiers
private extension View {

	@ViewBuilder func itemPickerSubtitle(_ subtitle: String?) -> some View {
		if let subtitle, !subtitle.isEmpty {
			if #available(iOS 26.0, *) {
				navigationSubtitle(subtitle)
			} else {
				safeAreaInset(edge: .top, spacing: 0) {
					Text(subtitle)
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding()
				}
			}
		} else {
			self
		}
	}
}
