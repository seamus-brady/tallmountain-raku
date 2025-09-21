# Contributing to TallMountain

Thank you for your interest in contributing to TallMountain! This document provides guidelines for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally
3. Create a new branch for your feature or bug fix
4. Make your changes
5. Test your changes thoroughly
6. Submit a pull request

## Development Setup

1. Install Raku (Rakudo Star recommended)
2. Run the dependency installation script:
   ```bash
   ./_scripts/install_deps.sh
   ```
3. Set up your environment variables (copy `.env.example` to `.env`)
4. Run the tests to ensure everything works:
   ```bash
   make test
   ```

## Coding Standards

- Follow Raku best practices and idioms
- Use meaningful variable and method names
- Include comprehensive documentation for public APIs
- Write tests for new functionality
- Keep methods focused and single-purpose
- Use descriptive commit messages

## Testing

All new features should include tests. Run the test suite with:

```bash
make test
```

## Areas for Contribution

We particularly welcome contributions in these areas:

### Core Platform
- Additional LLM provider integrations
- Performance optimizations
- Memory management improvements

### AI Safety & Ethics
- Enhanced threat detection algorithms
- New scanner implementations
- Improved normative reasoning capabilities
- Additional ethical frameworks

### User Experience
- Web interface improvements
- CLI enhancements
- Better error messages and debugging tools
- Documentation and tutorials

### Research & Theory
- Implementation of new cognitive architectures
- Advanced normative calculus features
- Integration with formal verification tools

## Submitting Changes

1. **Create an Issue**: For significant changes, create an issue first to discuss the approach
2. **Branch Naming**: Use descriptive branch names (e.g., `feature/new-scanner`, `fix/memory-leak`)
3. **Commit Messages**: Use clear, descriptive commit messages
4. **Pull Request**: Provide a clear description of what your PR does and why

### Pull Request Checklist

- [ ] Code follows project style guidelines
- [ ] Tests pass locally
- [ ] New features include tests
- [ ] Documentation updated if needed
- [ ] No unnecessary changes or formatting-only modifications
- [ ] Clear description of changes in PR

## License

By contributing to TallMountain, you agree that your contributions will be licensed under the MIT License.

## Questions?

If you have questions about contributing, feel free to:
- Open an issue for discussion
- Review existing code for examples
- Check the main README for architecture details

Thank you for helping make TallMountain better!