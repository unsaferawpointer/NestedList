//
//  Sound.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.07.2026.
//

public enum Sound: Hashable {
	case mark
	case unmark
	case place
}

public extension Sound {

	var name: String {
		switch self {
		case .mark:		"mark"
		case .unmark:	"unmark"
		case .place:	"place"
		}
	}
}
