/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 The scene delegate for the main browser for this application.
 */

import UIKit
import os.log

@available(iOS 13.0, *)
class SceneDelegate: UIResponder {
	private let router = SceneRouter()
}

// MARK: - UIWindowSceneDelegate
extension SceneDelegate: UIWindowSceneDelegate {

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		router.showWindow(for: scene, options: connectionOptions)
	}

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let urlContext = URLContexts.first else {
			return
		}
		router.handleDocument(url: urlContext.url)
	}
}
