import Foundation
import Testing
@testable import CorePresentation

@MainActor struct OnboardingPlayerTests { }

// MARK: - Repeating playback
extension OnboardingPlayerTests {

	@Test func playback_consumesEveryDurationAndRepeatsFromInitialState() async {
		// Arrange
		let initial = [item()]
		let scenario = OnboardingScenario(initial: initial) {
			Wait(.milliseconds(600))
			Change(duration: .milliseconds(250)) { $0[0].isSelected = true }
			Change(duration: .milliseconds(300)) { $0[0].title.strikethrough = true }
		}
		let clock = ManualSleeper()
		let sut = OnboardingPlayer(scenario: scenario, sleep: clock.sleep)
		let run = Task { await sut.run() }

		// Act / Assert: release each declared duration explicitly.
		await clock.waitForRequests(1)
		#expect(sut.items == initial)
		clock.advance()
		await clock.waitForRequests(2)
		#expect(sut.items[0].isSelected)
		#expect(!sut.items[0].title.strikethrough)
		clock.advance()
		await clock.waitForRequests(3)
		#expect(sut.items == scenario.final)
		clock.advance()
		await clock.waitForRequests(4)
		#expect(sut.items == initial)
		#expect(clock.durations == [.milliseconds(600), .milliseconds(250), .milliseconds(300), .milliseconds(600)])
		run.cancel()
		clock.advance()
		await run.value
	}

	@Test func zeroDurationSteps_doNotSleepButNoOpChangesKeepTheirDuration() async {
		// Arrange
		let scenario = OnboardingScenario(initial: [item()]) {
			Wait(.zero)
			Change(duration: .zero) { $0.removeAll() }
			Change(duration: .seconds(1)) { _ in }
		}
		let clock = ManualSleeper()
		let sut = OnboardingPlayer(scenario: scenario, sleep: clock.sleep)
		let run = Task { await sut.run() }

		// Act
		await clock.waitForRequests(1)
		run.cancel()
		clock.advance()
		await run.value

		// Assert
		#expect(sut.items.isEmpty)
		#expect(clock.durations == [.seconds(1)])
	}

	@Test func trailingWait_holdsFinalStateAcrossMultipleCyclesWithoutReevaluatingChanges() async {
		// Arrange
		let initial = [item()]
		var evaluations = 0
		let scenario = OnboardingScenario(initial: initial) {
			Wait(.seconds(1))
			Change(duration: .zero) { items in
				evaluations += 1
				items[0].isSelected = true
			}
			Wait(.seconds(2))
		}
		let clock = ManualSleeper()
		let sut = OnboardingPlayer(scenario: scenario, sleep: clock.sleep)
		let run = Task { await sut.run() }

		// Act / Assert
		for cycle in 0..<3 {
			await clock.waitForRequests(cycle * 2 + 1)
			#expect(sut.items == initial)
			clock.advance()
			await clock.waitForRequests(cycle * 2 + 2)
			#expect(sut.items == scenario.final)
			#expect(evaluations == 1)
			if cycle < 2 { clock.advance() }
		}
		run.cancel()
		clock.advance()
		await run.value
		#expect(clock.durations == [.seconds(1), .seconds(2), .seconds(1), .seconds(2), .seconds(1), .seconds(2)])
	}

	@Test func emptyScenario_isStatic() async {
		// Arrange
		let scenario = OnboardingScenario(initial: [item()]) { }
		let clock = ManualSleeper()
		let sut = OnboardingPlayer(scenario: scenario, sleep: clock.sleep)

		// Act
		await sut.run()

		// Assert
		#expect(sut.items == scenario.initial)
		#expect(clock.durations.isEmpty)
	}
}

// MARK: - Task cancellation and ownership
extension OnboardingPlayerTests {

	@Test(arguments: [false, true])
	func cancellation_preventsNextPublication(duringChange: Bool) async {
		// Arrange
		let scenario = OnboardingScenario(initial: [item()]) {
			Change(duration: duringChange ? .seconds(1) : .zero) { $0[0].isSelected = true }
			Wait(duringChange ? .zero : .seconds(1))
			Change(duration: .zero) { $0.removeAll() }
		}
		let clock = ManualSleeper()
		let sut = OnboardingPlayer(scenario: scenario, sleep: clock.sleep)
		let run = Task { await sut.run() }
		await clock.waitForRequests(1)
		let frozen = sut.items

		// Act
		run.cancel()
		clock.advance()
		await run.value

		// Assert
		#expect(sut.items == frozen)
		#expect(clock.durations.count == 1)
	}

	@Test func restart_cancelledTaskCannotOverwriteNewCycle() async {
		// Arrange
		let scenario = waitingScenario()
		let clock = ManualSleeper()
		let sut = OnboardingPlayer(scenario: scenario, sleep: clock.sleep)
		let oldRun = Task { await sut.run() }
		await clock.waitForRequests(1)

		// Act
		oldRun.cancel()
		let newRun = Task { await sut.run() }
		await clock.waitForRequests(2)
		clock.advance()
		await oldRun.value

		// Assert
		#expect(sut.items == scenario.initial)
		clock.advance()
		await clock.waitForRequests(3)
		#expect(sut.items == scenario.final)
		newRun.cancel()
		clock.advance()
		await newRun.value
	}

	@Test func replacement_usesIndependentPlayerForNewScenario() async {
		// Arrange
		let first = waitingScenario()
		let second = OnboardingScenario(initial: [item("Replacement")]) { }
		let clock = ManualSleeper()
		let oldPlayer = OnboardingPlayer(scenario: first, sleep: clock.sleep)
		let newPlayer = OnboardingPlayer(scenario: second, sleep: clock.sleep)
		let oldRun = Task { await oldPlayer.run() }
		await clock.waitForRequests(1)

		// Act
		oldRun.cancel()
		await newPlayer.run()
		clock.advance()
		await oldRun.value

		// Assert
		#expect(newPlayer.items == second.initial)
		#expect(oldPlayer.items == first.initial)
		#expect(clock.durations.count == 1)
	}

	@Test func presentations_haveIndependentPlaybackState() async {
		// Arrange
		let scenario = waitingScenario()
		let firstClock = ManualSleeper()
		let secondClock = ManualSleeper()
		let first = OnboardingPlayer(scenario: scenario, sleep: firstClock.sleep)
		let second = OnboardingPlayer(scenario: scenario, sleep: secondClock.sleep)
		let firstRun = Task { await first.run() }
		let secondRun = Task { await second.run() }
		await firstClock.waitForRequests(1)
		await secondClock.waitForRequests(1)

		// Act
		firstClock.advance()
		await firstClock.waitForRequests(2)

		// Assert
		#expect(first.items == scenario.final)
		#expect(second.items == scenario.initial)
		firstRun.cancel()
		secondRun.cancel()
		firstClock.advance()
		secondClock.advance()
		await firstRun.value
		await secondRun.value
	}
}

// MARK: - Nested data structs
private extension OnboardingPlayerTests {

	func item(_ title: String = "Task") -> OnboardingItem {
		OnboardingItemBuilder(title: title).build()
	}

	func waitingScenario() -> OnboardingScenario {
		OnboardingScenario(initial: [item()]) {
			Wait(.seconds(1))
			Change(duration: .zero) { $0[0].isSelected = true }
			Wait(.seconds(1))
		}
	}

	/// Deliberately ignores cancellation to exercise obsolete-run protection.
	@MainActor final class ManualSleeper {

		var durations: [Duration] = []
		private var pending: [CheckedContinuation<Void, any Error>] = []
		private var observers: [(Int, CheckedContinuation<Void, Never>)] = []

		func sleep(_ duration: Duration) async throws {
			try await withCheckedThrowingContinuation { continuation in
				durations.append(duration)
				pending.append(continuation)
				let ready = observers.filter { $0.0 <= durations.count }
				observers.removeAll { $0.0 <= durations.count }
				for (_, observer) in ready { observer.resume() }
			}
		}

		func waitForRequests(_ count: Int) async {
			guard durations.count < count else { return }
			await withCheckedContinuation { observers.append((count, $0)) }
		}

		func advance() {
			pending.removeFirst().resume()
		}
	}
}
