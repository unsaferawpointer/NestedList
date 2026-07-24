@testable import Hierarchy

// MARK: - RandomizableIdentifier
extension Int: RandomizableIdentifier {

	public static func random() -> Int {
		return Int.random(in: .min ... .max)
	}
}

// MARK: - RandomizableIdentifier
extension String: RandomizableIdentifier {

	public static func random() -> String {
		return String(Int.random())
	}
}
