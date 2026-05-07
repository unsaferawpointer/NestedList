//
//  GlobalCoordinatorTests.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 07.05.2026.
//

import Testing
import UniformTypeIdentifiers
import CoreModule
import CorePresentation
@testable import Nested_List

@MainActor struct GlobalCoordinatorTests {

	@Test func startShowsOnboardingWhenLastVersionIsMissing() throws {
		// Arrange
		let settingsProvider = StateProviderMock<Settings>()
		settingsProvider.stubs.state = .init(lastOnboardingVersion: nil)
		let version = Version(major: 2)
		let infoProvider = InfoProviderMock(version: version)
		let router = GlobalRouterMock()
		let sut = makeSUT(settingsProvider: settingsProvider, infoProvider: infoProvider, router: router)

		// Act
		sut.start()

		// Assert
		#expect(router.invocations.first == .showOnboarding(version: version))
	}

	@Test func startDoesNotShowOnboardingWhenAppVersionIsMissing() throws {
		// Arrange
		let settingsProvider = StateProviderMock<Settings>()
		settingsProvider.stubs.state = .init(lastOnboardingVersion: .init(rawValue: "1.0.0"))
		let infoProvider = InfoProviderMock(version: nil)
		let router = GlobalRouterMock()
		let sut = makeSUT(settingsProvider: settingsProvider, infoProvider: infoProvider, router: router)

		// Act
		sut.start()

		// Assert
		#expect(router.invocations.isEmpty)
	}

	@Test func startShowsOnboardingWhenCurrentVersionIsNewer() throws {
		// Arrange
		let settingsProvider = StateProviderMock<Settings>()
		settingsProvider.stubs.state = .init(lastOnboardingVersion: .init(rawValue: "1.0.0"))
		let version = Version(major: 2)
		let infoProvider = InfoProviderMock(version: version)
		let router = GlobalRouterMock()
		let sut = makeSUT(settingsProvider: settingsProvider, infoProvider: infoProvider, router: router)

		// Act
		sut.start()

		// Assert
		#expect(router.invocations.first == .showOnboarding(version: version))
	}

	@Test func startShowsOnboardingWhenNeeded() throws {
		// Arrange
		let settingsProvider = StateProviderMock<Settings>()
		settingsProvider.stubs.state = .init(lastOnboardingVersion: .init(rawValue: "1.0.0"))
		let version = Version(major: 2)
		let infoProvider = InfoProviderMock(version: version)
		let router = GlobalRouterMock()
		let sut = makeSUT(settingsProvider: settingsProvider, infoProvider: infoProvider, router: router)

		// Act
		sut.start()

		// Assert
		#expect(router.invocations.count == 1)
		#expect(router.invocations.first == .showOnboarding(version: version))
	}

	@Test func startDoesNotShowOnboardingWhenVersionIsMissing() throws {
		// Arrange
		let settingsProvider = StateProviderMock<Settings>()
		settingsProvider.stubs.state = .init(lastOnboardingVersion: nil)
		let infoProvider = InfoProviderMock(version: nil)
		let router = GlobalRouterMock()
		let sut = makeSUT(settingsProvider: settingsProvider, infoProvider: infoProvider, router: router)

		// Act
		sut.start()

		// Assert
		#expect(router.invocations.isEmpty)
	}

	@Test func importFileLoadsPickedURL() throws {
		// Arrange
		let url = URL(fileURLWithPath: "/tmp/file.txt")
		let router = GlobalRouterMock(openPanelURL: url)
		let documentController = DocumentControllerMock()
		let sut = makeSUT(router: router, documentController: documentController)

		// Act
		sut.importFile()

		// Assert
		#expect(router.invocations.contains(.showOpenPanel))
		#expect(documentController.invocations.count == 1)
		#expect(documentController.invocations.first?.url == url)
		#expect(documentController.invocations.first?.type == .plainText)
	}

	@Test func showPreferencesRoutesToPreferencesScreen() throws {
		// Arrange
		let router = GlobalRouterMock()
		let sut = makeSUT(router: router)

		// Act
		sut.showPreferences()

		// Assert
		#expect(router.invocations.contains(.showPreferences))
	}
}

// MARK: - Helpers
private extension GlobalCoordinatorTests {

	func makeSUT(
		settingsProvider: StateProviderMock<Settings> = {
			let provider = StateProviderMock<Settings>()
			provider.stubs.state = .standart
			return provider
		}(),
		infoProvider: InfoProviderMock = .init(version: nil),
		router: GlobalRouterMock = .init(),
		documentController: DocumentControllerMock = .init()
	) -> ClobalCoordinator {
		return ClobalCoordinator(
			settingsProvider: settingsProvider,
			infoProvider: infoProvider,
			router: router,
			documentController: documentController
		)
	}
}
