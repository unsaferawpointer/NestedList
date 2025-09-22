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

	private var pageControl: UIPageControl = {
		let control = UIPageControl()
		return control
	}()

	// MARK: - DI by property

	var viewDelegate: (any BoardViewDelegate)?

	// MARK: - DI by initialization

	let storage: DocumentStorage<Content>

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>, configure: (BoardViewController) -> Void) {
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

		setViewControllers(
			[
				ContentUnitAssembly.build(storage: storage)
			],
			direction: .forward,
			animated: true
		)

		let item = UIBarButtonItem(customView: pageControl)

		if #available(iOS 26.0, *) {
			(parent as? ToolbarSupportable)?.displayToolbar(top: [], bottom: [.fixedSpace(), item, .fixedSpace()])
		} else {
			// Fallback on earlier versions
		}
	}

	func updatePageControl() {
		pageControl.numberOfPages = columns.count
	}
}

// MARK: - BoardView
extension BoardViewController: BoardView {

	func display(columns: [UUID]) {
		self.columns = columns

		updatePageControl()
	}
}

// MARK: - UIPageViewControllerDataSource
extension BoardViewController: UIPageViewControllerDataSource {

	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {
		ContentUnitAssembly.build(storage: storage)
	}
	
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {
		ContentUnitAssembly.build(storage: storage)
	}
}

extension BoardViewController: UIPageViewControllerDelegate {

	func pageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool
	) {
		
	}
}
