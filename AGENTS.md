# AGENTS.md

Context file for AI agents working on nvm.

**Dual Format**: This file combines Category A (Operations Manual) and Category B (Context Guide) for comprehensive agent guidance.

## Project Overview

nvm is a Javascript project using npm/Node.js.

**Key Info:**
- **Primary Language:** Javascript
- **Build System:** npm/Node.js
- **Test Framework:** Jest
- **Total Files:** 446
- **Test Files:** 398
- **AI Readiness Score:** 74/100 (AI-Native)

---

## 🚨 AI Policy & Operations

Extracted from CONTRIBUTING.md - operational constraints and procedures.

### AI Policy

- The following is a set of guidelines for contributing to `nvm` managed by [@LJHarb](https://github.com/ljharb), which is hosted on GitHub. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.
- Commit the changes to your branch, including a coherent commit message that follows our [standards](#commit-messages)
- See the rest of the conventions [here](https://gist.github.com/ljharb/772b0334387a4bee89af24183114b3c7)

### Development Procedures

- Please refer to the [README](README.md) for complete instructions how to install, update, as well as troubleshoot `nvm` in your environment depending on your Operating System.
- Please include tests. Changes with tests will be merged very quickly.
- Please manually confirm that your changes work in `bash`, `sh`/`dash`, `ksh`, and `zsh`. Fast tests do run in these shells, but it's nice to manually verify also.
- Any time you make a change to your PR, please rebase freshly on top of the default branch. Nobody likes merge commits.
- git commit -a



## 🏗️ Architecture & Context Guide

This section provides architectural context and agent-understanding for the codebase.

### Prerequisites

- **Javascript:** 16+ (or applicable language version)
- **Package Manager:** npm or yarn
- **Test Runner:** Jest



### Project Structure

```
nvm/
├── Makefile
├── package.json
├── package.json
├── src/                  # Source code
├── tests/                # Test suite (398 files)
└── README.md             # Project documentation
```

### Architecture Overview

#### Key Components
- **Main Entry:** index.js
- **Test Suite:** 398 test files
- **Build Configuration:** Makefile, package.json, package.json

#### Design Principles

1. **Modularity** - Code organized by functionality with clear separation of concerns
2. **Testability** - Comprehensive test coverage across critical paths
3. **Clarity** - Explicit naming and structure for AI agent understanding
4. **Consistency** - Uniform patterns and conventions throughout codebase
5. **Maintainability** - Well-documented code with clear intent

### Directory Map

| Directory | Purpose |
|-----------|----------|
| `test/` | Test suite |


### Development Workflow

#### Initial Setup

```bash
git clone https://github.com/YOUR_ORG/nvm.git
cd nvm
npm install
# or
yarn install
```

#### Development Commands

**Running Tests:**
```bash
npm test                  # Run all tests
npm run test -- --watch   # Watch mode
npm run lint              # Lint code
```

#### Code Quality
```bash
npm run format            # Format code (prettier)
npm run lint -- --fix     # Auto-fix lint issues
```

### Code Style & Conventions

- **Naming:** Use Javascript conventions (snake_case for functions, PascalCase for classes)
- **Type Hints:** No (strongly encouraged)
- **Error Handling:** No - handle errors at boundaries; let exceptions propagate when another layer owns recovery
- **Logging:** Yes
- **Testing:** Yes - write tests alongside code changes

### Testing Strategy

**Framework:** Jest
**Test Files:** 398 found

Before committing:
1. Run the full test suite: `npm test` or `yarn test`
2. Run linter: `npm run lint` or `yarn lint`
3. Format code: `npm run format` or `yarn format`
4. Type check (if TypeScript): `npm run type-check`

### Writing Documentation

When updating docs:
1. Always include explanatory text before code snippets
2. Describe *why* and *what* before showing *how*
3. Keep sections focused on a single concept
4. Use clear, concrete examples

## Known Gotchas & Warnings

- **Describe the exact steps which reproduce the problem** in as many details as possible. For example, start by explaining which command exactly you used in the terminal. When listing steps, **don't just say what you did, but explain how you did it**. For example, if you moved the cursor to the end of a line, explain if you used the mouse, or a keyboard shortcut or a command, and if so which one?
- Even if you don't have all of these items covered, please still feel free to submit a PR/issue! Someone else may be inspired and volunteer to complete it for you.
- **Note:**  Add co-authors to your commit message for commits with multiple authors

### Contributing Guidelines

This project has a detailed contribution guide at **`CONTRIBUTING.md`**.

**Key Requirements:**
- Review the contribution guide for all requirements
- Follow established patterns in the codebase
- Ensure alignment with project's contribution policies

### Common Patterns

When contributing to this project:
1. Read existing code in the area you're modifying
2. Follow the established patterns and style
3. Write tests for new functionality
4. Use clear, descriptive variable and function names
5. Add docstrings for public APIs
6. Update tests when changing behavior

### What We Value

✅ Well-tested code with clear intent
✅ Consistent code style and naming conventions
✅ Code that is easy for AI agents to understand
✅ Clear, descriptive commit messages
✅ Modular, reusable components
✅ Comprehensive documentation

### What We Avoid

❌ Large functions doing multiple things
❌ Commented-out dead code
❌ Inconsistent naming or patterns
❌ Unclear error messages
❌ Unexplained magic numbers or strings
❌ Skipped tests or test TODOs

### AI Readiness Dimensions (Scoring)

This project is evaluated across 8 dimensions:

1. **Architecture** (15/100) - Code organization and modularity
2. **Testing** (15/100) - Test coverage and quality
3. **Dependencies** (12/100) - Dependency management
4. **Conventions** (2/100) - Consistent patterns
5. **Entry Points** (7/100) - Clear main/start locations
6. **Security** (5/100) - Input validation and error handling
7. **Build** (10/100) - Clear build/setup instructions
8. **Documentation** (8/100) - Code and project documentation

### Next Steps

Before making changes:
1. Read relevant source files to understand the existing code
2. Look at existing tests for similar functionality
3. Follow the patterns you see in the codebase
4. Write tests for your changes
5. Run `pytest` to verify nothing breaks
6. Run code quality checks: `ruff check . && mypy .`
7. Format your code: `ruff format .`

---

*Generated by Braxis - keeping AI agents in sync with your code*

