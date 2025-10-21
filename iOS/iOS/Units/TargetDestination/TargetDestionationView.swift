//
//  TargetDestionationView.swift
//  iOS
//
//  Created by Anton Cherkasov on 27.09.2025.
//

import SwiftUI
import CoreModule

struct TargetDestionationView: View {

	@Bindable var model: TargetDestinationViewModel

	private var completionHandler: ((UUID?, Bool) -> Void)?

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>, movingItems: Set<UUID>, completionHandler: ((UUID?, Bool) -> Void)?) {
		self.model = TargetDestinationViewModel(storage: storage, movingItems: movingItems)
		self.completionHandler = completionHandler
	}

	var body: some View {
		NavigationStack {
			List {
				Section {
					Text("root_item_title", tableName: "TargetDestinationLocalizable")
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
						.onTapGesture {
							completionHandler?(nil, true)
						}
				}
				Section {
					ForEach(model.filteredItems) { item in
						ItemView(model: item)
						.contentShape(Rectangle())
						.onTapGesture {
							completionHandler?(item.id, true)
						}
					}
				}

				Section {
					ForEach(model.unavailableItems) { item in
						ItemView(model: item)
					}
				} header: {
					VStack(alignment: .leading) {
						Text("unavailable_section_title", tableName: "TargetDestinationLocalizable")
						Text("unavailable_section_subtitle", tableName: "TargetDestinationLocalizable")
							.foregroundStyle(.secondary)
							.font(.caption)
					}
				}
			}
			.listStyle(.insetGrouped)
			.searchable(text: $model.searchText)
			.navigationTitle(String(localized: "navigation_title", table: "TargetDestinationLocalizable"))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						completionHandler?(nil, false)
					} label: {
						Image(systemName: "xmark")
					}
				}
			}
		}
	}
}
