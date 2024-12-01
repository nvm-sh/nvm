# Contributing

:+1::tada: First off, thanks for taking the time to contribute to `nvm`! :tada::+1:

We love pull requests and issues, they're our favorite.

The following is a set of guidelines for contributing to `nvm` managed by [@LJHarb](https://github.com/ljharb), which is hosted on GitHub. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

However, before submitting, please review the following:

# How Can I Contribute?

There are lots of ways to get involved. Here are some suggestions of things we'd love some help with.

## Resolving existing issues

You can consider helping out with issues already requiring attention - look for a "help wanted" label.

### How Do I Submit a (Good) Bug Report? :bug:

Explain the problem and include additional details to help maintainers reproduce the problem:

* **Use a clear and descriptive title** for the issue to identify the problem.

* **Describe the exact steps which reproduce the problem** in as many details as possible. For example, start by explaining which command exactly you used in the terminal. When listing steps, **don't just say what you did, but explain how you did it**. For example, if you moved the cursor to the end of a line, explain if you used the mouse, or a keyboard shortcut or a command, and if so which one?
* **Provide specific examples to demonstrate the steps**. Include links to files or Github projects, or copy/pasteable snippets, which you use in those examples. If you're providing snippets in the issue, use [Markdown code blocks](https://help.github.com/articles/markdown-basics/#multiple-lines).
* **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
* **Explain which behavior you expected to see instead and why.**
* **Provide as much context as possible** in order to help others verify and ultimately fix the issue. This includes giving us as much details as possible about your environment, so we can more easily confirm the problem.

## Documentation

We are happy to welcome contributions from anyone willing to improve documentation by adding missing information or making it more consistent and coherent.

# Dev Environment

Please refer to the [README](README.md) for complete instructions how to install, update, as well as troubleshoot `nvm` in your environment depending on your Operating System.

# Style Guide / Coding conventions

### Pull requests

#### Before creating a pull request

  - Please include tests. Changes with tests will be merged very quickly.
  - Please manually confirm that your changes work in `bash`, `sh`/`dash`, `ksh`, and `zsh`. Fast tests do run in these shells, but it's nice to manually verify also.
  - Please maintain consistent whitespace - 2-space indentation, trailing newlines in all files, etc.
  - Any time you make a change to your PR, please rebase freshly on top of the default branch. Nobody likes merge commits.

Even if you don't have all of these items covered, please still feel free to submit a PR/issue! Someone else may be inspired and volunteer to complete it for you.

#### How to create a pull request

Create a new branch

```
git checkout -b issue1234
```

Commit the changes to your branch, including a coherent commit message that follows our [standards](#commit-messages)

```
git commit -a
```

Before sending the pull request, make sure your code is running on the latest available code by rebasing onto the upstream source

```
git fetch upstream
git rebase upstream/main
```

Verify your changes

```
npm test
```

Push your changes

```
git push origin issue1234
```

Send the [pull request](https://docs.github.com/en/pull-requests), make requested changes, and get merged.

### Commit Messages

* Limit the first line of the commit message (message summary) to 72 characters or less.
* Use the present tense ("Add feature" not "Added feature") and imperative mood ("Move cursor to..." not "Moves cursor to...") when providing a description of what you did.
* If your PR addresses an issue, reference it in the body of the commit message.
* See the rest of the conventions [here](https://gist.github.com/ljharb/772b0334387a4bee89af24183114b3c7)

#### Commit message example

```
[Tag]: Short description of what you did

Longer description here if necessary

Fixes #1234
```

> **Note:**  Add co-authors to your commit message for commits with multiple authors

```
Co-authored-by: Name Here <email@here>
```


# Code of Conduct
[Code of Conduct](https://github.com/nvm-sh/nvm/blob/HEAD/CODE_OF_CONDUCT.md)

# Where can I ask for help?
If you have any questions, please contact [@LJHarb](mailto:ljharb@gmail.com).

# Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:
  - The contribution was created in whole or in part by me and I have the right to submit it under the open source license indicated in the file; or
  - The contribution is based upon previous work that, to the best of my knowledge, is covered under an appropriate open source license and I have the right under that license to submit that work with modifications, whether created in whole or in part by me, under the same open source license (unless I am permitted to submit under a different license), as indicated in the file; or
  - The contribution was provided directly to me by some other person who certified (a), (b) or (c) and I have not modified it.
  - I understand and agree that this project and the contribution are public and that a record of the contribution (including all personal information I submit with it, including my sign-off) is maintained indefinitely and may be redistributed consistent with this project or the open source license(s) involved.
