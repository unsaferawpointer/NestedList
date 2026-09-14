// MARK: - Traversal
public extension TreeNode {

	/// Traverses this subtree depth-first, preserving child order, without recursive calls.
	///
	/// Calls `enter` before visiting children and `leave` after visiting all descendants.
	/// If `enter` throws, traversal stops immediately without calling pending `leave` handlers.
	/// This traversal does not detect cycles; the caller can reject them in `enter`.
	func traverse<Failure: Error>(
		enter: (Self) throws(Failure) -> Void,
		leave: (Self) -> Void = { _ in }
	) throws(Failure) {
		var pending = [TreeVisit<Self>.enter(self)]
		while let visit = pending.popLast() {
			switch visit {
			case let .enter(node):
				try enter(node)
				pending.append(.leave(node))
				pending.append(
					contentsOf: node.children
						.reversed()
						.map {
							.enter($0)
						}
				)
			case let .leave(node):
				leave(node)
			}
		}
	}
}

// MARK: - Traversal events
private enum TreeVisit<T: TreeNode> {
	case enter(T)
	case leave(T)
}
