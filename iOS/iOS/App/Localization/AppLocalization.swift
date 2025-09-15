//
//  AppLocalization.swift
//  iOS
//
//  Created by Anton Cherkasov on 15.09.2025.
//

import Foundation

protocol AppLocalizable {
	var newFileName: String { get }
}

final class AppLocalization { }

// MARK: - AppLocalizable
extension AppLocalization: AppLocalizable {

	var newFileName: String {
		String(localized: "new-file-name", table: "AppLocalizable")
	}
}
