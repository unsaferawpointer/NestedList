//
//  SceneRouter.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.05.2026.
//

import UIKit

final class SceneRouter {
	private var window: UIWindow?
}

// MARK: - Public Interface
extension SceneRouter {

	func showWindow(for scene: UIScene, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else {
			return
		}
		window = UIWindow(windowScene: windowScene)
		window?.rootViewController = UINavigationController(
			rootViewController: DocumentViewController(document: nil)
		)
		window?.makeKeyAndVisible()

		if let urlContext = connectionOptions.urlContexts.first {
			handleDocument(url: urlContext.url)
		}

		if let onboardingViewController = OnboardingAssembly.build(settingsProvider: .shared) {
			window?.rootViewController?.present(onboardingViewController, animated: true)
		}
	}

	func handleDocument(url: URL) {
		guard let root = (window?.rootViewController as? UINavigationController)?.viewControllers.first as? DocumentViewController else {
			return
		}
		root.launchOptions.browserViewController.revealDocument(at: url, importIfNeeded: true) { revealedURL, error in
			guard let revealedURL else {
				return
			}
			root.document = Document(fileURL: revealedURL)
		}
	}
}
