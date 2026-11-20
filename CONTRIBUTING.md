# Contributing Guidelines for SKAVIA

Thank you for your interest in the **SKAVIA** project. 

SKAVIA is an independently authored, proprietary service and workforce management platform developed and maintained by **Timon Biswas** ([@Ti838](https://github.com/Ti838)).

While the core source code is proprietary, external code reviews, bug reports, and structured improvements from invited collaborators are welcome under the terms set forth below.

---

## 1. Code Contribution Agreement

By submitting a Pull Request, issue, or patch to this repository:
1. You acknowledge and agree that your contribution is provided voluntarily without compensation or claim of co-ownership over SKAVIA.
2. You grant the Author (**Timon Biswas**) an irrevocable, perpetual, worldwide, non-exclusive, royalty-free license to use, incorporate, adapt, and distribute your contribution as part of SKAVIA.
3. You warrant that the submitted code is your own original work and does not infringe on third-party copyrights, patents, or trade secrets.

---

## 2. Development Workflow & Clean Architecture Standards

All code submissions must comply with the established **Modular Clean Architecture**:

### A. Flutter Mobile Guidelines (`lib/`)
- **No Monolithic Files:** Keep files strictly single-responsibility.
  - Page widgets: 100–250 lines.
  - Component widgets: 30–150 lines.
  - Controllers/Services: 100–250 lines.
- **Strict Architecture Boundaries:** Business logic must reside in domain repositories or controllers (`ChangeNotifier` / `StateNotifier`), completely decoupled from UI widgets.
- **Zero Analyzer Errors:** Every PR must cleanly pass:
  ```powershell
  dart analyze --fatal-infos
  flutter test
  ```
- **Responsive Layout Guarantee:** Every screen must support small 320dp widths, 1.5x/2.0x text scaling, and both Light and Dark modes without `RenderFlex` overflow.

### B. Admin Web Guidelines (`admin-web/`)
- Adhere to the Next.js 15 App Router structure and TypeScript strictness.
- Every PR must pass:
  ```powershell
  cd admin-web
  npm run lint
  npm run typecheck
  npm test
  npm run build
  ```

---

## 3. Pull Request Process

1. **Branch Naming:**
   - Feature: `feat/feature-name`
   - Bug fix: `fix/bug-description`
   - Refactoring: `refactor/scope-description`
   - Documentation: `docs/documentation-update`
2. **Commit Convention:**
   Follow Conventional Commits (`feat(auth): ...`, `fix(router): ...`, `refactor(worker): ...`, `docs(api): ...`).
3. **Testing Requirements:**
   Every new feature or bug fix must be accompanied by comprehensive unit or integration tests verifying edge cases and boundary conditions.
