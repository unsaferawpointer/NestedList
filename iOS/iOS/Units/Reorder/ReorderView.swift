//
//  ReorderView.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.09.2025.
//

import SwiftUI

import CoreModule
import CorePresentation

struct ReorderView {

	@Bindable var model: ReorderViewModel

	private var completionHandler: (() -> Void)?

	// MARK: - Initialization

	init(
		item: UUID,
		storage: DocumentStorage<DocumentContent>,
		analytics: any ConcreteAnalyticsServiceProtocol<ReorderAnalyticsEvent> = ConcreteAnalyticsService<ReorderAnalyticsEvent>(),
		completionHandler: (() -> Void)?
	) {
		self.model = ReorderViewModel.init(
			item: item,
			storage: storage,
			analytics: analytics
		)
		self.completionHandler = completionHandler
	}
}

// MARK: - View
extension ReorderView: View {

	var body: some View {
		NavigationStack {
			List {
				ForEach(model.items) { item in
					ItemView(model: item)
				}.onMove { indices, target in
					withAnimation {
						model.move(fromOffsets: indices, toOffset: target)
					}
				}
			}
			.listStyle(.plain)
			.environment(\.editMode, .constant(.active))
			.navigationTitle(String(localized: "navigation_title", table: "ReorderLocalizable"))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						model.close()
						completionHandler?()
					} label: {
						Image(systemName: "xmark")
					}
				}
			}
			.onAppear {
				model.show()
			}
		}
	}
}
