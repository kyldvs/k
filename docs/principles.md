# Less but Better

> **Note:** These are important principles in this repository that should always be followed.

Software engineering principles inspired by Dieter Rams' design philosophy: "Weniger, aber besser" (Less, but better).

Good design is not about adding features—it's about removing everything that doesn't serve a purpose. Every line of code is a liability. Every abstraction is a cost. The best solution is the one that solves the problem with the least complexity.

## 1. Good Code is Innovative

Innovation means solving problems in new ways, not using new technology for its own sake.

- Choose boring technology for boring problems
- Innovate only where it creates clear value
- Let constraints drive creative solutions
- Question "the way we've always done it"
- Measure innovation by outcomes, not novelty

## 2. Good Code is Useful

Code exists to solve problems. If it doesn't make the product more useful, it doesn't belong.

- Solve real problems, not imagined ones
- Build what users need, not what you want to build
- Validate assumptions before implementing
- Delete features that aren't used
- Optimize for the common case

## 3. Good Code is Aesthetic

Code is read far more than written. Aesthetic code is pleasant to read and reveals its intent.

- Consistent formatting and naming
- Symmetry and patterns over exceptions
- Whitespace and structure aid comprehension
- Beauty emerges from constraint, not decoration
- If it looks wrong, it probably is wrong

## 4. Good Code is Understandable

Clarity is not optional. Code should be obvious at a glance.

- Names reveal intent and domain concepts
- Functions do one thing at the right level of abstraction
- Control flow is linear and predictable
- Clever is the enemy of clear
- Complexity should be unavoidable, not accidental

## 5. Good Code is Unobtrusive

Good abstractions fade into the background, letting you focus on the problem domain.

- Don't force users to learn your framework
- Convention over configuration
- Sensible defaults for 90% of cases
- Power for the 10% who need it
- Infrastructure should be invisible when it works

## 6. Good Code is Honest

Code should be exactly what it appears to be. No surprises, no hidden behavior.

- Functions do what their names say
- Types reflect actual constraints
- Errors surface immediately, not later
- No action at a distance
- Performance characteristics match intuition

## 7. Good Code is Long-lasting

Code should age gracefully. Write for maintainers, not just for now.

- Dependencies are minimized and justified
- Standards outlive frameworks
- Fundamental patterns over temporary trends
- Documentation explains why, not what
- Backwards compatibility is a feature

## 8. Good Code is Thorough

Quality is in the details. Incomplete work creates friction for everyone who follows.

- Handle edge cases explicitly
- Validate inputs, assert invariants
- Test behavior, not implementation
- Logging for debugging, metrics for monitoring
- Every detail serves a purpose

## 9. Good Code is Sustainable

Software development is a marathon. Optimize for the long term.

- Technical debt is tracked and addressed
- Build time is a feature
- Cognitive load is minimized
- Energy and resources are conserved
- Team happiness enables sustainability

## 10. Good Code is as Little Code as Possible

The best code is no code. The second best is less code.

- Delete more than you add
- Reuse before writing
- Compose instead of building from scratch
- Solve the actual problem, not the general case
- When in doubt, do less

---

**Less, but better.** This is not about minimalism for its own sake—it's about respecting the people who will read, maintain, and live with your code. Every line should earn its place. Every abstraction should pay for its complexity. Every feature should solve a real problem.

If you can't explain why it needs to exist, it probably doesn't.
