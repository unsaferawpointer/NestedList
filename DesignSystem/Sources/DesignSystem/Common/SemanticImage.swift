//
//  SemanticIcon.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 02.05.2025.
//

#if canImport(AppKit)

import AppKit

fileprivate typealias Image = NSImage

#elseif canImport(UIKit)

import UIKit

fileprivate typealias Image = UIImage

#endif

public enum SemanticImage: Int {

	case point = 0

	// MARK: - Objects
	case folder = 10
	case docText = 11
}

// MARK: - Codable
extension SemanticImage: Codable { }

// MARK: - Hashable
extension SemanticImage: Hashable { }

#if canImport(AppKit)
// MARK: - Computed properties
public extension SemanticImage {

	var image: NSImage? {
		switch self {
		case .folder: NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
		case .docText: NSImage(systemSymbolName: "doc.text", accessibilityDescription: nil)
		case .point: NSImage(named: "point")
		}
	}
}
#elseif canImport(UIKit)
// MARK: - Computed properties
public extension SemanticImage {


	var image: UIImage? {
		switch self {
		case .folder: UIImage(systemName: "folder")
		case .docText: UIImage(systemName: "doc.text")
		case .point: UIImage(named: "point")
		}
	}
}
#endif
