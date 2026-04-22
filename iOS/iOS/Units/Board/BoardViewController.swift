//
//  BoardViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.09.2025.
//

import UIKit

import CoreModule
import DesignSystem

protocol BoardView: AnyObject {
	func display(columns: [UUID])
}

protocol BoardViewDelegate: ViewDelegate { }

class BoardViewController: UIPageViewController {

	private var columns: [UUID] = []

	// MARK: - UI - Properties

	private lazy var pageControl: UIPageControl = {
		let control = UIPageControl()
		control.allowsContinuousInteraction = false
		return control
	}()

	// MARK: - DI by property

	var viewDelegate: (any BoardViewDelegate)?

	// MARK: - DI by initialization

	let storage: DocumentStorage<Content>

	let router: RouterProtocol

	// MARK: - Initialization

	init(router: RouterProtocol, storage: DocumentStorage<Content>, configure: (BoardViewController) -> Void) {
		self.router = router
		self.storage = storage
		super.init(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal,
			options: nil
		)
		configure(self)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - UIViewController Life-Cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		configureViewController()

		viewDelegate?.viewDidChange(state: .didLoad)
	}

}

// MARK: - Private
private extension BoardViewController {

	func configureViewController() {
		self.dataSource = self
		self.delegate = self

		if let first = columns.first {
			setViewControllers(
				[
					ContentUnitAssembly.build(for: first, router: router, storage: storage)
				],
				direction: .forward,
				animated: true
			)
		}

		let pageControlItem = UIBarButtonItem(customView: pageControl)

		(parent as? ToolbarSupportable)?
			.displayToolbar(
				top: [],
				bottom: [.flexibleSpace(),
						 pageControlItem,
						 .flexibleSpace()],
				showUndoGroup: false
			)
	}

	func updatePageControl() {
		pageControl.numberOfPages = columns.count
	}
}

// MARK: - BoardView
extension BoardViewController: BoardView {

	func display(columns: [UUID]) {
		self.columns = columns

		if viewControllers == nil || viewControllers?.isEmpty == true, let first = columns.first {
			setViewControllers(
				[
					ContentUnitAssembly.build(for: first, router: router, storage: storage)
				],
				direction: .forward,
				animated: true
			)
		}

		updatePageControl()
	}
}

// MARK: - UIPageViewControllerDataSource
extension BoardViewController: UIPageViewControllerDataSource {

	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {
		guard
			let tableController = viewController as? TableViewController,
			let root = tableController.id, let index = columns.firstIndex(of: root), index > 0
		else {
			return nil
		}
		let nextIndex = index - 1
		return ContentUnitAssembly.build(for: columns[nextIndex], router: router, storage: storage)
	}
	
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {
		guard
			let tableController = viewController as? TableViewController,
			let root = tableController.id, let index = columns.firstIndex(of: root), index < columns.count - 1
		else {
			return nil
		}
		let nextIndex = index + 1
		return ContentUnitAssembly.build(for: columns[nextIndex], router: router, storage: storage)
	}
}

extension BoardViewController: UIPageViewControllerDelegate {

	func pageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool
	) {
		guard
			completed, let current = pageViewController.viewControllers?.first as? TableViewController,
			let id = current.id, let index = columns.firstIndex(of: id)
		else {
			return
		}

		pageControl.currentPage = index
	}
}
