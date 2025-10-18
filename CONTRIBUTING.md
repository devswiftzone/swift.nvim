# Contributing to swift.nvim

Thanks for your interest in improving swift.nvim! Contributions of all kinds are
welcome—bug reports, documentation updates, new features, and refactors. This
guide explains how to get started and what we expect from contributions.

## Getting Started

1. Fork the repository and clone your fork locally.
2. Create a topic branch off `main`. Use a descriptive name such as
   `feature/lldb-breakpoints` or `fix/target-detection`.
3. Install dependencies listed in `DEPENDENCIES.md` so you can exercise the
   plugin end-to-end.
4. Add the local checkout to your Neovim config. With lazy.nvim this can be as
   simple as:
   ```lua
   {
     dir = "~/projects/nvim/swift.nvim",
     ft = "swift",
     dev = true,
   }
   ```
5. Use the samples in `examples/` to get up and running quickly. They provide
   known-good configurations for testing.

## Development Workflow

- Keep changes focused. If you are fixing multiple unrelated issues, prefer
  separate pull requests.
- Draft PRs are encouraged for early feedback. Add a checklist to track progress
  if the work is still ongoing.
- Update the relevant documentation (`DOCUMENTATION.md`, `GETTING_STARTED.md`,
  etc.) whenever behavior changes or new features are added.
- Reference related issues in commit messages and pull requests using GitHub
  keywords (`Fixes #123`) when applicable.

## Coding Standards

- Match the surrounding Lua style (two-space indentation, descriptive variable
  names, and idiomatic Neovim APIs).
- Break complex logic into well-named helper functions. Keep modules focused on
  a single responsibility.
- When adding user-facing commands, document them in `DOCUMENTATION.md` and
  provide an example in `examples/` if it helps new users.
- For documentation, use plain Markdown and prefer short paragraphs for
  readability.

## Testing and Verification

- Exercise changes manually in Neovim using the minimal or full configuration
  examples to ensure they work in real projects.
- Run `:checkhealth swift` in Neovim to make sure all health checks pass before
  submitting.
- Add automated tests if you introduce utility functions that can be validated
  without a running Neovim instance. (A lightweight busted or plenary test
  suite is welcome—open an issue to discuss the approach first.)

## Submitting a Pull Request

1. Verify your branch builds and behaves as expected.
2. Ensure commits are rebased on top of the latest `main` and have clear
   messages.
3. Fill in the pull request template completely so reviewers understand the
   change, testing strategy, and any outstanding questions.
4. Be responsive to review feedback—discuss alternatives openly and document any
   trade-offs made.

### Review Process

- **Initial Response**: You can expect an initial response within 3-5 business
  days.
- **Reviewers**: Core maintainers will review all pull requests. Check the
  [CODEOWNERS](https://github.com/devswiftzone/swift.nvim/blob/main/.github/CODEOWNERS)
  file for specific areas of ownership.
- **Approval**: Pull requests require at least one approving review from a core
  maintainer before merging.
- **CI/CD**: All automated checks must pass before merging.

## License and Copyright

By contributing to swift.nvim, you agree that your contributions will be
licensed under the same [MIT License](LICENSE) that covers the project. You
retain copyright to your contributions, but grant swift.nvim maintainers and
users the rights specified in the MIT License.

### Contributor Agreement

- You confirm that your contribution is your original work or that you have the
  right to submit it under the project's license.
- You understand and agree that your contributions are public and that a record
  of the contribution (including all personal information submitted with it) is
  maintained indefinitely.
- You agree to the [Code of Conduct](CODE_OF_CONDUCT.md).

We appreciate every contribution. Thank you for helping make swift.nvim better
for the whole community!
