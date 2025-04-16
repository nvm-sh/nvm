# Contributing

:+1::tada: First off, thanks for taking the time to contribute to `nvm`! :tada::+1:

We love pull requests and issues — they're our favorite.
This document is a set of guidelines for contributing to `nvm`, managed by [@LJHarb](https://github.com/ljharb) and hosted on GitHub.

These are guidelines, not strict rules — use your best judgment and feel free to propose improvements.

---

## 🚀 How Can I Contribute?

There are many ways to get involved! Here are some ideas:

### 🛠 Resolve Existing Issues

Start by checking out open issues with the **`help wanted`** label.

### 🐞 Submitting a Good Bug Report

When filing a bug, please include:

- A **clear and descriptive title**
- A list of **exact steps to reproduce the issue**, with details (keyboard vs. mouse, commands used, etc.)
- **Code snippets or links** to demonstrate the problem
- A **description of the observed behavior**
- An **explanation of what you expected instead**
- **Environment details** (OS, terminal, shell, `nvm` version)

> Use [Markdown code blocks](https://help.github.com/articles/markdown-basics/#multiple-lines) for code.

---

## 📚 Documentation Contributions

Want to improve the docs? Awesome! We welcome all enhancements to improve clarity, correctness, and structure.

---

## 🧑‍💻 Dev Environment Setup

See the [README](README.md) for detailed setup and usage instructions based on your OS.

---

## 💻 Code Style & PR Guidelines

### Before Submitting a PR

- ✅ Add tests
- ✅ Verify your changes in `bash`, `sh`/`dash`, `ksh`, and `zsh`
- ✅ Use consistent whitespace (2-space indentation, trailing newlines, etc.)
- ✅ Rebase your PR against `upstream/main` — **no merge commits**

> PRs without all these aren't blocked — we’re happy to help finish them!

---

### 🧪 Run Tests

```bash
npm test
