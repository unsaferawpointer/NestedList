//
//  ItemSignView.swift
//  macOS
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import SwiftUI

struct ItemSignView: View {

	var body: some View {
		Circle()
			.fill(
				Color(nsColor: .secondarySystemFill)
			)
			.frame(width: 8, height: 8)
	}
}

#Preview {
	ItemSignView()
}
