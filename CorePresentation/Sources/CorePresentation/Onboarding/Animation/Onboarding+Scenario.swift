import DesignSystem
import Foundation

// MARK: - Reference scenarios
extension Onboarding {

	/// Build once and retain each prepared value for its scene's lifetime.
	@MainActor static func makeSubitemsScenario(
		initial: [OnboardingItem] = OnboardingItemsFactory.makeItems()
	) -> OnboardingScenario {
		guard let parentIndex = initial.firstIndex(where: { $0.id == String.appUpdate }) else {
			assertionFailure("Missing onboarding parent")
			return OnboardingScenario()
		}
		let text = "Prepare release checklist"
		let newItem = OnboardingItemBuilder(title: .init(value: "", showsCaret: true))
			.icon(.init(name: .asteriskPoint, token: .primary))
			.selected()
			.build(id: String.releaseChecklist)
		var typedItem = newItem
		typedItem.title.value = text
		typedItem.title.showsCaret = false
		typedItem.isSelected = false
		typedItem.level = initial[parentIndex].level + 1
		let descendants = initial.dropFirst(parentIndex + 1).prefix { $0.level > initial[parentIndex].level }
		let children = [typedItem] + descendants

		return OnboardingScenario(initial: initial) {
			addingSubitem(parentID: String.appUpdate, newItem: newItem, text: text)
			togglingSubitems(parentID: String.appUpdate, children: children)
			Wait(.seconds(2))
		}
	}

	static func makeCustomizationScenario(
		initial: [OnboardingItem] = makeSubitemsScenario().final
	) -> OnboardingScenario {
		OnboardingScenario(initial: initial) {
			Wait(.milliseconds(800))
			customizingItems()
			Wait(.seconds(2))
		}
	}

	static func makeMirrorsScenario(
		initial: [OnboardingItem] = makeCustomizationScenario().final
	) -> OnboardingScenario {
		guard
			let originalIndex = initial.firstIndex(where: { $0.id == String.releaseChecklist }),
			let destinationIndex = initial.firstIndex(where: { $0.id == String.today })
		else {
			assertionFailure("Missing onboarding mirror source or destination")
			return OnboardingScenario()
		}
		let text = initial[originalIndex].title.value + " for launch"
		var items = initial
		for index in items.indices {
			items[index].isSelected = false
		}
		items[originalIndex].title.value = ""
		items[originalIndex].title.strikethrough = false
		items[originalIndex].title.colorToken = .primary
		items[originalIndex].title.showsCaret = true
		items[originalIndex].icon.appearence = .monochrome(token: .primary)
		items[originalIndex].isSelected = true
		var mirror = items[originalIndex]
		mirror.id = String.releaseChecklistMirror
		mirror.icon.name = .linkPoint
		mirror.level = items[destinationIndex].level + 1
		mirror.state = .leaf
		mirror.showsTrailingDisclosure = false
		items.insert(mirror, at: destinationIndex + 1)

		return OnboardingScenario(initial: items) {
			Wait(.milliseconds(800))
			usingMirrors(identifiers: [String.releaseChecklist, String.releaseChecklistMirror], text: text)
		}
	}
}

// MARK: - Private methods
private extension Onboarding {

	@OnboardingScenarioBuilder
	static func addingSubitem(
		parentID: String,
		newItem: OnboardingItem,
		text: String
	) -> [OnboardingScenarioBuilder.Operation] {
		Wait(.milliseconds(800))
		Change(duration: .milliseconds(250)) { items in
			let parentIndex = self.index(of: parentID, in: items)
			for index in items.indices {
				items[index].isSelected = false
			}
			items[parentIndex].state = .expanded
			var child = newItem
			child.level = items[parentIndex].level + 1
			items.insert(child, at: parentIndex + 1)
		}
		Wait(.milliseconds(350))
		typing(text, into: [newItem.id])
		Change(duration: .zero) { items in
			let index = self.index(of: newItem.id, in: items)
			items[index].title.showsCaret = false
		}
		Wait(.seconds(1))
	}

	@OnboardingScenarioBuilder
	static func togglingSubitems(
		parentID: String,
		children: [OnboardingItem]
	) -> [OnboardingScenarioBuilder.Operation] {
		Change(duration: .milliseconds(250)) { items in
			let index = self.index(of: parentID, in: items)
			for row in items.indices {
				items[row].isSelected = items[row].id == parentID
			}
			items[index].state = .collapsed
			let childIDs = Set(children.map(\.id))
			items.removeAll {
				childIDs.contains($0.id)
			}
		}
		Wait(.milliseconds(800))
		Change(duration: .milliseconds(250)) { items in
			let index = self.index(of: parentID, in: items)
			items[index].state = .expanded
			items[index].isSelected = false
			items.insert(contentsOf: children, at: index + 1)
		}
	}

	@OnboardingScenarioBuilder
	static func customizingItems() -> [OnboardingScenarioBuilder.Operation] {
		customizingRoot(id: String.projects, icon: .squareStack)
		customizingRoot(id: String.today, icon: .calendar, color: .red)
		Change(duration: .milliseconds(150)) { items in
			for index in items.indices {
				items[index].isSelected = items[index].id == String.releaseChecklist
			}
		}
		Wait(.milliseconds(250))
		Change(duration: .milliseconds(150)) { items in
			let index = self.index(
				of: String.releaseChecklist,
				in: items
			)
			items[index].title.strikethrough = true
			items[index].title.colorToken = .disabledText
			items[index].icon.appearence = .monochrome(token: .tertiary)
		}
		Wait(.milliseconds(700))
		Change(duration: .milliseconds(150)) { items in
			for index in items.indices {
				items[index].isSelected = false
			}
		}
		Wait(.milliseconds(400))
	}

	@OnboardingScenarioBuilder
	static func customizingRoot(
		id: String,
		icon: SemanticImage,
		color: ColorToken? = nil
	) -> [OnboardingScenarioBuilder.Operation] {
		Change(duration: .milliseconds(150)) { items in
			for index in items.indices {
				items[index].isSelected = items[index].id == id
			}
		}
		Wait(.milliseconds(250))
		Change(duration: .milliseconds(150)) { items in
			let index = self.index(of: id, in: items)
			items[index].icon.name = icon
		}
		if let color {
			Wait(.milliseconds(250))
			Change(duration: .milliseconds(150)) { items in
				let index = self.index(of: id, in: items)
				items[index].icon.appearence = .monochrome(token: color)
			}
		}
		Wait(.milliseconds(400))
		Change(duration: .milliseconds(150)) { items in
			for index in items.indices {
				items[index].isSelected = false
			}
		}
	}

	@OnboardingScenarioBuilder
	static func usingMirrors(
		identifiers: [String],
		text: String
	) -> [OnboardingScenarioBuilder.Operation] {
		typing(text, into: identifiers)
		Change(duration: .zero) { items in
			for index in items.indices where identifiers.contains(items[index].id) {
				items[index].title.showsCaret = false
			}
		}
		Wait(.milliseconds(500))
		Change(duration: .milliseconds(150)) { items in
			for index in items.indices where identifiers.contains(items[index].id) {
				items[index].title.strikethrough = true
				items[index].title.colorToken = .disabledText
				items[index].icon.appearence = .monochrome(token: .tertiary)
			}
		}
		Wait(.seconds(2))
	}

	@OnboardingScenarioBuilder
	static func typing(
		_ text: String,
		into identifiers: [String]
	) -> [OnboardingScenarioBuilder.Operation] {
		for endIndex in text.indices {
			let value = String(text[...endIndex])
			Change(duration: .zero) { items in
				for id in identifiers {
					let index = self.index(of: id, in: items)
					items[index].title.value = value
				}
			}
			Wait(.milliseconds(65))
		}
	}
}

// MARK: - Helpers
private extension Onboarding {

	static func index(of id: String, in items: [OnboardingItem]) -> Int {
		guard let index = items.firstIndex(where: { $0.id == id }) else {
			fatalError("Missing onboarding item: \(id)")
		}
		return index
	}
}
