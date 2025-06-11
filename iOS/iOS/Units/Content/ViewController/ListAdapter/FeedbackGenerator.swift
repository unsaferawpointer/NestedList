//
//  FeedbackGenerator.swift
//  iOS
//
//  Created by Anton Cherkasov on 11.06.2025.
//

import UIKit

final class FeedbackGenerator {

	private var feedbackGenerator: UIImpactFeedbackGenerator?
}

// MARK: - Public Interface
extension FeedbackGenerator {

	func impactOccurred(style: UIImpactFeedbackGenerator.FeedbackStyle) {
		// Завершаем работу генератора
		feedbackGenerator = UIImpactFeedbackGenerator(style: style)
		feedbackGenerator?.prepare()
		feedbackGenerator?.impactOccurred()
		feedbackGenerator = nil
	}
}
