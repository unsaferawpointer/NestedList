//
//  CompositeIconGeometry.swift
//  DesignSystem
//

import Foundation

struct CompositeIconGeometry {

	let iconWidth: CGFloat
	let iconHeight: CGFloat

	let badgeSideRatio: CGFloat
	let badgePaddingRatio: CGFloat
	let badgeOverlapRatio: CGFloat

	var badgeSide: CGFloat {
		iconWidth * badgeSideRatio
	}

	var badgePadding: CGFloat {
		iconWidth * badgePaddingRatio
	}

	var badgeCutoutSide: CGFloat {
		badgeSide + 2 * badgePadding
	}

	var badgeOverlap: CGFloat {
		badgeCutoutSide * badgeOverlapRatio
	}

	var badgeProtrusion: CGFloat {
		badgeCutoutSide - badgeOverlap
	}

	var intrinsicContentSize: CGSize {
		CGSize(
			width: iconWidth + badgeProtrusion,
			height: contentHeight
		)
	}

	var mainIconOriginY: CGFloat {
		#if os(macOS)
		max(0, badgeProtrusion - badgePadding)
		#else
		badgeProtrusion
		#endif
	}

	func frames(isRightToLeft: Bool) -> Frames {
		#if os(iOS)
		let badgeCutoutY: CGFloat = mainIconOriginY + iconHeight - badgeOverlap
		#else
		let badgeCutoutY: CGFloat = mainIconOriginY - badgeProtrusion
		#endif
		return Frames(
			mainIcon: CGRect(
				x: isRightToLeft ? 0 : badgeProtrusion,
				y: mainIconOriginY,
				width: iconWidth,
				height: iconHeight
			),
			badgeCutout: CGRect(
				x: isRightToLeft ? iconWidth - badgeOverlap : 0,
				y: badgeCutoutY,
				width: badgeCutoutSide,
				height: badgeCutoutSide
			)
		)
	}
}

// MARK: - Private properties
private extension CompositeIconGeometry {

	var contentHeight: CGFloat {
		#if os(macOS)
		iconHeight + mainIconOriginY
		#else
		iconHeight + 2 * badgeProtrusion
		#endif
	}
}

// MARK: - Nested data structs
extension CompositeIconGeometry {

	struct Frames {
		let mainIcon: CGRect
		let badgeCutout: CGRect
	}
}
