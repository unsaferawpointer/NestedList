/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 The scene delegate for the main browser for this application.
 */

import UIKit
import os.log
import CoreSettings

@available(iOS 13.0, *)
class SceneDelegate: UIResponder {

	var window: UIWindow?
	var securityScopedURL: URL?
}

// MARK: - UIWindowSceneDelegate
extension SceneDelegate: UIWindowSceneDelegate {

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {

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

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		if let urlContext = URLContexts.first {
			handleDocument(url: urlContext.url)
		}
	}
}

// MARK: - Helpers
private extension SceneDelegate {

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
