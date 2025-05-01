//
//  FileLoader.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 22.02.2025.
//

import Foundation

final class FileLoader {

	func loadFile(_ name: String) -> String? {
		let bundle = Bundle.module
		guard
			let path = bundle.url(forResource: name, withExtension: "txt"),
			let data = try? Data(contentsOf: path)
		else {
			return nil
		}

		return String(data: data, encoding: .utf8)
	}

	func loadFile(_ name: String, fileExtension: String) -> Data? {
		let bundle = Bundle.module
		guard
			let path = bundle.url(forResource: name, withExtension: fileExtension),
			let data = try? Data(contentsOf: path)
		else {
			return nil
		}

		return data
	}
}
