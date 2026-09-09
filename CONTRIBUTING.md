# Contributing to OpenCloud Helm Charts

Thank you for your interest in contributing to the OpenCloud Helm Charts repository!

## Repository Structure

This repository follows a community-driven approach with a simple role model:

- **Contributors**: Anyone who submits PRs
- **Reviewers**: Experienced contributors who can review and approve PRs
- **Maintainers**: Active reviewers who can additionally merge PRs and manage releases

## Contribution Workflow

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR-USERNAME/helm.git
cd helm
git remote add upstream https://github.com/opencloud-eu/helm.git
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

### 3. Make Changes and Test

When making changes, please ensure you:
- Follow Helm best practices
- Include proper documentation
- Run the required chart validation commands below

#### Required Helm validation

From the repository root, run both commands before opening or updating a PR:

```bash
helm lint charts/opencloud --strict
helm unittest charts/opencloud
```

`helm-unittest` is a Helm plugin. Install it once if it is not available:

```bash
# The plugin repository does not publish Helm provenance metadata.
helm plugin install --verify=false https://github.com/helm-unittest/helm-unittest.git
```

Also render the chart for a basic syntax check:

```bash
helm template test charts/opencloud >/dev/null
```

For changes affecting a deployed release, run the Helm integration tests as well:

```bash
helm test <release-name> --namespace <namespace>
```

### 4. Submit a Pull Request

- Create a PR from your fork to the main repository
- Ensure your PR has a clear description of the changes
- At least one reviewer must approve before a maintainer can merge

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).

## Becoming a Maintainer or Reviewer

Contributors who make multiple high-quality PRs may be invited to become Reviewers.
Reviewers who are consistently active and provide valuable reviews may be invited to become Maintainers.

If you're interested in becoming a maintainer or reviewer, please continue contributing and engaging with the project.
