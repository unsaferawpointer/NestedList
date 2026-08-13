## Context

See [proposal.md](proposal.md) for motivation. The macOS app structures its current list unit as Assembly → View Controller / Presenter / Interactor, with the assembly owning object construction and protocol-based dependencies between layers. The prior Column implementation was removed; the current change restores only the unit boundary, not its prior functionality.

## Goals / Non-Goals

**Goals:**

- Establish a compile-ready Column unit that follows current macOS assembly conventions.
- Keep all four concrete types connected through explicit protocols.
- Ensure reverse references are weak where required to avoid ownership cycles.

**Non-Goals:**

- Render a column or host a nested list.
- Read from or mutate `DocumentStorage`.
- Add lifecycle callbacks, presentation state, actions, menu items, analytics, localization, or tests for behavior that does not yet exist.

## Decisions

### Use a four-layer unit boundary

`ColumnUnitAssembly` creates `ColumnInteractor`, `ColumnPresenter`, and `ColumnViewController`. It assigns the view's output to the presenter, the presenter's interactor and weak view references, and the interactor's weak presenter reference.

This matches the existing macOS Content unit and provides a stable integration point for the future columns container. Restoring the old Column implementation was rejected because it depends on removed APIs and would bring in storage and UI behavior outside this change.

### Define protocol seams before behavior

The view output, unit view, interactor, and presenter protocols are declared now with no requirements. Concrete types depend on these interfaces rather than each other for their cross-layer references.

This avoids changing public behavior while providing the intended dependency directions for later changes. Adding speculative methods was rejected because their contracts cannot be validated until the columns container and interactions are designed.

## Risks / Trade-offs

- [Empty protocols may seem premature] → Keep their scope limited to the Column unit and add requirements only with concrete behavior.
- [The future columns UI needs a different shape] → The isolated assembly and protocol seams allow the unit to evolve without affecting the current Content unit.
