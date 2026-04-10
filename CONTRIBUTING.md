# Contributing to Pro Grocery

Thank you for your interest in Pro Grocery! This document provides guidelines for contributing to the project.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on solutions, not criticism
- Respect intellectual property and licensing

## Getting Started

### Prerequisites
- Flutter 3.9+ with Dart 3.9+
- Android Studio or VS Code
- Git

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/yourusername/Pro_Grocery.git
cd Pro_Grocery

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Project Structure
```
lib/
  ├── main.dart                 # App entry point
  ├── core/
  │   ├── components/          # Reusable UI components
  │   ├── config/              # App configuration
  │   ├── constants/           # App-wide constants
  │   ├── models/              # Data models
  │   ├── network/             # API clients
  │   ├── routes/              # Navigation routes
  │   ├── services/            # Business logic services
  │   ├── themes/              # Theme configuration
  │   └── utils/               # Utility functions
  └── views/
      ├── auth/                # Authentication screens
      ├── home/                # Home screen
      ├── cart/                # Shopping cart
      ├── checkout/            # Order checkout
      └── ...                  # Other screens
```

## Development Workflow

### 1. Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable/function names
- Add documentation comments for public APIs
- Maximum line length: 120 characters

### 2. Linting
```bash
# Run lint checks
dart analyze lib

# Format code
dart format lib

# Apply fixes
dart fix --apply lib
```

### 3. Testing
```bash
# Run widget tests
flutter test

# Run with coverage
flutter test --coverage
```

### 4. Git Workflow

**Branch Naming**:
- Feature: `feature/description`
- Bug fix: `bugfix/description`
- Documentation: `docs/description`

**Commit Messages**:
```
[TYPE] Short description

Longer explanation if needed.
- Bullet points for changes
- Reference issues with #123

Types: feat, fix, docs, style, refactor, test, chore
```

**Example**:
```
[feat] Add M-Pesa payment integration

- Implement M-Pesa API client
- Add payment status tracking
- Update checkout flow
- Fixes #42
```

## Making Changes

### Before Starting
1. Check existing issues to avoid duplicate work
2. Create a new issue to discuss major changes
3. Fork the repository and create a feature branch

### While Developing
1. Keep commits focused and logical
2. Test on multiple devices (360px, 390px, 414px, 768px)
3. Verify dark mode compatibility
4. Run `dart analyze lib` to catch issues
5. Update documentation if adding features

### Before Submitting
1. Ensure `dart analyze lib` returns "No issues found!"
2. Run `flutter test` and verify all tests pass
3. Test on actual devices or emulators
4. Review your own code first (self-review)
5. Rebase onto latest main branch

## Submitting Pull Requests

### PR Title Format
```
[TYPE] Brief description

Example: [feat] Add wishlist functionality
```

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Tested dark mode
- [ ] Tested responsive layouts

## Checklist
- [ ] Code follows style guidelines
- [ ] `dart analyze lib` passes
- [ ] `flutter test` passes
- [ ] Documentation updated
- [ ] No breaking changes

## Related Issues
Fixes #123
Related to #456
```

## Code Review Process

### For Authors
- Respond to feedback promptly
- Push updates to your branch (don't force push)
- Mark conversations as resolved after updates

### For Reviewers
- Provide constructive feedback
- Approve once satisfied with changes
- Check implementation against design specs

## What We Look For

✅ **Good PR**:
- Follows commit conventions
- Single responsibility
- Tests included
- Documentation updated
- No lint errors

❌ **Difficult to Review**:
- Multiple unrelated changes
- No explanation of changes
- Breaking changes without discussion
- Missing tests
- Hardcoded values instead of configuration

## Reporting Bugs

### Before Reporting
- Search existing issues (bug might already be reported)
- Try to reproduce on latest version
- Gather system information

### Bug Report Template
```
**Describe the bug**
Clear description of what's wrong

**Steps to reproduce**
1. Do this
2. Then that
3. Bug occurs

**Expected behavior**
What should happen

**Actual behavior**
What actually happens

**Device info**
- Device: iPhone 14 Pro
- OS: iOS 17.0
- Flutter: 3.9.0

**Screenshots/Video**
If applicable, add screenshots showing the issue

**Additional context**
Any other relevant information
```

## Feature Requests

### Before Requesting
- Check if feature already exists
- Verify it aligns with project goals
- Consider implementation difficulty

### Feature Request Template
```
**Describe the feature**
What functionality would you like?

**Use case**
Why is this feature needed?

**Proposed solution**
How should this work?

**Alternative approaches**
Other ways to solve this problem?

**Impact**
- User impact: High/Medium/Low
- Complexity: High/Medium/Low
```

## Documentation

### README Updates
- Document new features
- Update setup instructions if changed
- Add usage examples

### Code Comments
- Explain "why", not "what"
- Document complex algorithms
- Add examples for public APIs

### Changelog
Update [CHANGELOG.md](CHANGELOG.md) with:
```markdown
## [1.0.1] - 2026-04-10
### Added
- New feature description

### Fixed
- Bug fix description

### Changed
- API change description

### Deprecated
- Deprecated feature description
```

## Performance Guidelines

Before submitting:
- ✅ Animations are smooth (60fps)
- ✅ App loads in <3 seconds
- ✅ Scroll performance is jank-free
- ✅ No memory leaks in Provider state
- ✅ Network calls use proper caching

## Accessibility Requirements

All UI components must:
- ✅ Have minimum 48x48dp touch targets
- ✅ Support 4.5:1 contrast ratio
- ✅ Include semantic labels
- ✅ Work with screen readers
- ✅ Support keyboard navigation

## Release Process

Maintainers will:
1. Review and approve PRs
2. Merge to main branch
3. Tag release version
4. Create GitHub release notes
5. Deploy update

## Getting Help

- **Questions**: Open a discussion on GitHub
- **Bugs**: File an issue with reproduction steps
- **Security**: Email security@progrocery.co
- **Licensing**: See LICENSE.md

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE.md).

---

## Recognition

Contributors will be:
- Listed in [CONTRIBUTORS.md](CONTRIBUTORS.md)
- Acknowledged in release notes
- Featured in community highlights

Thank you for making Pro Grocery better! 🚀
