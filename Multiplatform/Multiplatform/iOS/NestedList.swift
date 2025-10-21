//
//  NestedList.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 14.09.2025.
//

import SwiftUI

struct NestedList: View {

	typealias Item = ItemView.Item

	@State var items: [Item] = [
		Item(
	  iconName: "folder",
	  title: "Documents",
	  subtitle: "12 items",
	  children: [
		  Item(iconName: "pdf", title: "Report.pdf", subtitle: "2.4 MB"),
		  Item(iconName: "document", title: "Notes.txt", subtitle: "15 KB"),
		  Item(
			  iconName: "folder",
			  title: "Projects",
			  subtitle: "3 items",
			  children: [
				  Item(iconName: "code", title: "app.swift", subtitle: "45 KB"),
				  Item(iconName: "code", title: "utils.swift", subtitle: "28 KB")
			  ]
		  )
	  ]
  ),
  Item(
	  iconName: "folder",
	  title: "Images",
	  subtitle: "8 items",
	  children: [
		  Item(iconName: "image", title: "photo1.jpg", subtitle: "4.2 MB"),
		  Item(iconName: "image", title: "photo2.png", subtitle: "3.1 MB")
	  ]
  ),
  Item(
	  iconName: "music",
	  title: "Audio Files",
	  subtitle: nil,
	  children: nil
  ),
  Item(
	  iconName: "video",
	  title: "Presentation.mov",
	  subtitle: "156 MB"
  )
]

	@State private var editMode: EditMode = .inactive

	@State var selection: Set<UUID> = []

	@State var scrollPosition: ScrollPosition = .init()

	var body: some View {
		List(items, children: \.children, selection: $selection) { item in
			ItemView(item: item)
				.contextMenu {
					Button(role: .none) {

					} label: {
						Label("Move...", systemImage: "arrow.up.arrow.down")
					}
					Divider()
					Button(role: .destructive) {

					} label: {
						Label("Delete", systemImage: "trash")
					}
				}
				.id(item.id)
		}
		.scrollPosition($scrollPosition)
		.environment(\.editMode, $editMode)
		.listStyle(.insetGrouped)
		.overlay {
			if items.isEmpty {
				ContentUnavailableView {
					Label("No Mail", systemImage: "tray.fill")
				} description: {
					Text("New mails you receive will appear here.")
				}
			}
		}
		.toolbar {
			ToolbarItem {
				Button(editMode.isEditing ? "Done" : "Edit") {
					withAnimation {
						editMode = editMode.isEditing ? .inactive : .active
					}
				}
			}

			ToolbarSpacer()
			ToolbarItem(placement: .primaryAction) {
				if editMode.isEditing == true {
					Menu {
						Button {

						} label: {
							Label("Strikethrough", systemImage: "checkmark")
						}
						Divider()
						Button(role: .destructive) {
							withAnimation {
								items.removeAll { item in
									selection.contains(item.id)
								}
								editMode = .inactive
							}
						} label: {
							Label("Delete", systemImage: "trash")
						}
					} label: {
						Image(systemName: "ellipsis")
					}
				} else {
					Button {
						let item = Item(title: "New item")
						withAnimation {
							items.append(item)
							scrollPosition = .init(id: item.id, anchor: .bottom)
						}
					} label: {
						Image(systemName: "plus")
					}
				}
			}
		}
		.toolbarVisibility(.visible, for: .bottomBar)
	}
}

#Preview {
	NavigationStack {
		NestedList()
	}
}
