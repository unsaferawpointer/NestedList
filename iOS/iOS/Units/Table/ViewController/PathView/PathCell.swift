import UIKit

class PathCell: UICollectionViewCell {

	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		let size = contentView.systemLayoutSizeFitting(
			CGSize(width: UIView.layoutFittingCompressedSize.width, height: layoutAttributes.size.height),
			withHorizontalFittingPriority: .fittingSizeLevel,
			verticalFittingPriority: .required
		)
		let attributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
		attributes.size.width = max(1, ceil(size.width))
		return attributes
	}
}
