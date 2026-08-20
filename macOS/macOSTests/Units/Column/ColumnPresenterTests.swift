import CoreModule
import CorePresentation
import DesignSystem
import Foundation
import Testing
@testable import Nested_List

@MainActor
struct ColumnPresenterTests {

	@Test func menuItems_includeAppearanceActions() {
		let sut = makeSUT()

		#expect(sut.menuItems() == [
			.columnEdit,
			.separator,
			.toggleStrikethrough,
			.separator,
			.appearanceHeader,
			.changeIcon,
			.changeColor,
			.separator,
			.moveForward,
			.moveBackward,
			.separator,
			.columnDelete
		])
	}

	@Test func changeIcon_confirmsSelectionAndTracksMenuClick() async {
		let interactor = ColumnInteractorMock()
		let router = UnitRouterMock()
		let analytics = ColumnAnalyticsMock()
		let sut = makeSUT(interactor: interactor, router: router, analytics: analytics)

		sut.menuItemClicked(.changeIcon, source: .context)
		router.stubs.showIconPickerCompletionHandler?(.bolt)

		#expect(interactor.invocations.contains(.setIcon(.bolt)))
		let event = await analytics.waitForEvent()
		#expect(event.name == .menuItemClick)
		#expect(event.parameters["id"] == .string(ColumnMenuIdentifier.changeIcon.rawValue))
	}

	@Test func changeColor_confirmsSelection() async {
		let interactor = ColumnInteractorMock()
		let router = UnitRouterMock()
		let sut = makeSUT(interactor: interactor, router: router)

		sut.menuItemClicked(.changeColor, source: .context)
		router.stubs.showColorPickerCompletionHandler?(.cyan)

		#expect(interactor.invocations.contains(.setColor(.cyan)))
	}

	@Test func toggleStrikethrough_usesCompletionBehaviourAndExposesState() {
		let interactor = ColumnInteractorMock()
		interactor.stubs.isStrikethrough = true
		let settings = StateProviderMock<Settings>()
		settings.stubs.state = .init(completionBehaviour: .moveToEnd)
		let sut = makeSUT(interactor: interactor, settings: settings)

		sut.menuItemClicked(.toggleStrikethrough, source: .context)

		#expect(interactor.invocations.contains(.toggleStrikethrough(moveToEnd: true)))
		#expect(sut.stateForMenuItem(.toggleStrikethrough) == .on)
	}
}

private extension ColumnPresenterTests {

	func makeSUT(
		interactor: ColumnInteractorMock = ColumnInteractorMock(),
		router: UnitRouterMock = UnitRouterMock(),
		settings: StateProviderMock<Settings> = StateProviderMock(),
		analytics: ColumnAnalyticsMock = ColumnAnalyticsMock()
	) -> ColumnPresenter {
		let sut = ColumnPresenter(router: router, settingsProvider: settings, analytics: analytics)
		sut.interactor = interactor
		return sut
	}
}

private final class ColumnInteractorMock {

	private(set) var invocations: [Action] = []
	var stubs = Stubs()
}

// MARK: - ColumnInteractorProtocol
extension ColumnInteractorMock: ColumnInteractorProtocol {

	func fetchData() { }
	func configure(for root: UUID) { }
	func rootItem() -> Item? { nil }
	func newItem(with properties: ItemProperties, target: UUID?) -> UUID { UUID() }
	func set(_ text: String, note: String?) { }

	func setIcon(_ name: IconName?) {
		invocations.append(.setIcon(name))
	}

	func setColor(_ color: ItemColor?) {
		invocations.append(.setColor(color))
	}

	func toggleStrikethrough(moveToEnd: Bool) {
		invocations.append(.toggleStrikethrough(moveToEnd: moveToEnd))
	}

	func isStrikethrough() -> Bool {
		stubs.isStrikethrough
	}

	func moveForward() { }
	func validateMovingForward() -> Bool { false }
	func moveBackward() { }
	func validateMovingBackward() -> Bool { false }
	func deleteColumn() { }
}

private extension ColumnInteractorMock {

	enum Action: Equatable {
		case setIcon(IconName?)
		case setColor(ItemColor?)
		case toggleStrikethrough(moveToEnd: Bool)
	}

	struct Stubs {
		var isStrikethrough = false
	}
}

private actor ColumnAnalyticsMock: ConcreteAnalyticsServiceProtocol {

	private var events: [ColumnAnalyticsEvent] = []
	private var eventContinuation: CheckedContinuation<ColumnAnalyticsEvent, Never>?

	func waitForEvent() async -> ColumnAnalyticsEvent {
		if let event = events.first {
			return event
		}
		return await withCheckedContinuation { continuation in
			eventContinuation = continuation
		}
	}

	func track(_ event: ColumnAnalyticsEvent) {
		events.append(event)
		eventContinuation?.resume(returning: event)
		eventContinuation = nil
	}

	func flush() { }
}
