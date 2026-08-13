## 1. Column unit scaffold

- [x] 1.1 Add `ColumnInteractor` and an empty `ColumnInteractorProtocol` in the macOS Column unit.
- [x] 1.2 Add `ColumnPresenter`, an empty `ColumnPresenterProtocol`, and empty view-facing protocols for the Column unit.
- [x] 1.3 Add a minimal `ColumnViewController` that holds its presenter output through the view-facing protocol.

## 2. Assembly wiring

- [x] 2.1 Add `ColumnUnitAssembly` to construct the four unit layers and assign their protocol-based dependencies.
- [x] 2.2 Use weak presenter-to-view and interactor-to-presenter references to avoid retain cycles.
- [x] 2.3 Build the macOS target to verify the scaffold compiles without introducing Column behavior.
