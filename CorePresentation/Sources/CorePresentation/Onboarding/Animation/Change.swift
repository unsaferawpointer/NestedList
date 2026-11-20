/// Transforms the complete collection once during scenario preparation.
/// All differences form one transition; zero duration applies them immediately.
struct Change {

	let duration: Duration
	let transform: (inout [OnboardingItem]) -> Void

	init(
		duration: Duration,
		_ transform: @escaping (inout [OnboardingItem]) -> Void
	) {
		self.duration = duration
		self.transform = transform
	}
}
