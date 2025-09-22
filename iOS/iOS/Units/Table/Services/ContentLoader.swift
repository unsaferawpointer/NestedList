//
//  ContentLoader.swift
//  iOS
//
//  Created by Anton Cherkasov on 31.05.2025.
//

import Foundation
import UniformTypeIdentifiers
import Hierarchy
import CoreModule

protocol ContentLoaderProtocol {
	func loadItems(providers: [NSItemProvider], completionHandler: @escaping ([Node<Item>]) -> Void) -> Bool
	func loadStrings(providers: [NSItemProvider], completionHandler: @escaping ([String]) -> Void) -> Bool
}

final class ContentLoader {

	private let itemType = "dev.zeroindex.ListAdapter.item"

	private let stringType = UTType.plainText.identifier
}

// MARK: - ContentLoaderProtocol
extension ContentLoader: ContentLoaderProtocol {

	func loadItems(providers: [NSItemProvider], completionHandler: @escaping ([Node<Item>]) -> Void) -> Bool {

		let filtered = providers.filter {
			$0.hasItemConformingToTypeIdentifier(itemType)
		}

		guard !filtered.isEmpty else {
			return false
		}

		var cache: [Int: Node<Item>] = [:]

		let group = DispatchGroup()
		let lock = NSLock()

		for (index, provider) in filtered.enumerated() {
			group.enter()
			_ = provider.loadDataRepresentation(forTypeIdentifier: itemType) { data, error in
				if let data, let node = try? JSONDecoder().decode(Node<Item>.self, from: data) {
					lock.lock()
					cache[index] = node
					lock.unlock()
				}
				group.leave()
			}
		}
		group.notify(queue: .main) {
			let nodes = providers.indices.compactMap {
				cache[$0]
			}
			completionHandler(nodes)
		}
		return true
	}

	func loadStrings(providers: [NSItemProvider], completionHandler: @escaping ([String]) -> Void) -> Bool {

		var cache: [Int: String] = [:]

		let filtered = providers.filter {
			$0.canLoadObject(ofClass: NSString.self)
		}

		guard !filtered.isEmpty else {
			return false
		}

		let group = DispatchGroup()
		let lock = NSLock()

		for (index, provider) in filtered.enumerated() {
			group.enter()
			_ = provider.loadObject(ofClass: NSString.self) { string, error in
				if let string = string as? String {
					lock.lock()
					cache[index] = string
					lock.unlock()
				}
				group.leave()
			}
		}
		group.notify(queue: .main) {
			let strings = providers.indices.compactMap {
				cache[$0]
			}
			completionHandler(strings)
		}
		return true
	}
}
