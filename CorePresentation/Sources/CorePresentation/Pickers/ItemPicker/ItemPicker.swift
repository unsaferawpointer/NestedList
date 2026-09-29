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
	@State private var isSearchPresented = false

	// MARK: - Initialization

	public init(
		storage: DocumentStorage<DocumentContent>,
		title: String,
		filter: @escaping (Item) -> Bool,
		analytics: any ConcreteAnalyticsServiceProtocol<ItemPickerAnalyticsEvent> = ConcreteAnalyticsService<ItemPickerAnalyticsEvent>(),
		completionHandler: @escaping @MainActor (UUID?, Bool) -> Void
	) {
		self.model = ItemPickerViewModel(
			storage: storage,
			title: title,
			filter: filter,
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
			.searchable(text: $model.searchText)
			.navigationTitle(model.title)
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
			}
			.listStyle(.inset)
			.searchable(
				text: $model.searchText,
				isPresented: $isSearchPresented,
				placement: .toolbar
			)
			.navigationTitle(model.title)
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

	struct ItemRow: View {

		let item: ItemPickerItem

		var body: some View {
			HStack(spacing: 8) {
				Text(item.title)
					.font(.body)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}
