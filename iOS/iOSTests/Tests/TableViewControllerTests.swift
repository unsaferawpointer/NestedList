import Testing
import UIKit
import CoreModule
import CorePresentation
import Hierarchy
@testable import iOS

@MainActor
struct TableViewControllerTests { }

// MARK: - Focus navigation interface
extension TableViewControllerTests {

	@Test(arguments: [CGSize(width: 393, height: 852), CGSize(width: 1024, height: 1366)])
	func focus_displaysPathOnSameScreenEvenWhenSubtreeIsEmpty(size: CGSize) throws {
		// Arrange
		let fixture = Fixture(size: size)
		let path = try #require(descendant(of: PathView.self, in: fixture.controller.view))

		// Act
		fixture.presenter.userDidTapMenu(with: .focus, selection: [fixture.child.id])
		fixture.controller.view.layoutIfNeeded()

		// Assert
		#expect(fixture.navigation.viewControllers.count == 1)
		#expect(fixture.navigation.topViewController === fixture.controller)
		#expect(fixture.controller.nestedList.isEmpty)
		#expect(!path.isHidden)
		#expect(path.bounds.height >= 44)
		#expect(fixture.controller.nestedList.frame.maxY >= path.frame.maxY)
		#expect(fixture.controller.nestedList.tableView.contentInset.bottom == path.bounds.height)
		#expect(fixture.controller.nestedList.tableView.verticalScrollIndicatorInsets.bottom == path.bounds.height)
		#expect(path.frame.maxY <= fixture.controller.view.bounds.maxY)
	}

	@Test func tappingDocumentPathComponentRestoresListAndHidesPath() throws {
		// Arrange
		let fixture = Fixture(size: CGSize(width: 393, height: 852))
		fixture.presenter.userDidTapMenu(with: .focus, selection: [fixture.child.id])
		let path = try #require(descendant(of: PathView.self, in: fixture.controller.view))
		let collection = try #require(descendant(of: UICollectionView.self, in: path))

		// Act
		collection.delegate?.collectionView?(collection, didSelectItemAt: IndexPath(item: 0, section: 0))
		fixture.controller.view.layoutIfNeeded()

		// Assert
		#expect(path.isHidden)
		#expect(fixture.controller.nestedList.tableView.contentInset.bottom == 0)
		#expect(!fixture.controller.nestedList.isEmpty)
		#expect(fixture.navigation.viewControllers.count == 1)
	}
}

// MARK: - Private methods
private extension TableViewControllerTests {

	func descendant<T: UIView>(of type: T.Type, in view: UIView) -> T? {
		if let match = view as? T {
			return match
		}
		return view.subviews.lazy.compactMap { descendant(of: type, in: $0) }.first
	}
}

// MARK: - Nested data structs
private extension TableViewControllerTests {

	@MainActor
	struct Fixture {
		let parent = Item(text: "Parent")
		let child = Item(text: "Child")
		let presenter: ContentPresenter
		let controller: TableViewController
		let navigation: UINavigationController

		init(size: CGSize) {
			let storage = DocumentStorage(
				stateProvider: StateProvider(initialState: DocumentContent(uuid: nil, nodes: [
					DocumentNode(value: parent, children: [DocumentNode(value: child, children: [])])
				])),
				contentProvider: DataProvider(),
				undoManager: nil
			)
			let interactor = ContentUnitInteractor(root: nil, storage: storage)
			let settings = StateProviderMock<Settings>()
			settings.stubs.state = Settings()
			let presenter = ContentPresenter(
				router: ContentRouterMock(),
				settingsProvider: settings,
				analytics: ContentAnalyticsMock(),
				soundPlayer: SoundPlayerMock()
			)
			presenter.interactor = interactor
			interactor.presenter = presenter
			self.presenter = presenter
			controller = TableViewController(id: nil) { view in
				presenter.view = view
				view.delegate = presenter
				view.nestedList.setDelegate(presenter)
			}
			navigation = UINavigationController(rootViewController: controller)
			navigation.view.frame = CGRect(origin: .zero, size: size)
			navigation.view.layoutIfNeeded()
			controller.loadViewIfNeeded()
			controller.view.frame = navigation.view.bounds
			controller.view.layoutIfNeeded()
		}
	}
}
