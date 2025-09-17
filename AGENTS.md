# Repository Guidelines

## Project Structure & Module Organization
The chart root contains `Chart.yaml`, default configuration in `values.yaml`, and reusable helper templates in `templates/_helpers.tpl`. Deployable manifests live in `templates/*.yaml` (deployment, service, ingress, HPA, service account). Helm test hooks reside in `templates/tests/`. Vendored charts belong in `charts/`, and GitHub workflows are tracked under `.github/workflows/`.

## Build, Test, and Development Commands
Run `helm lint .` to validate template syntax and required values; all pull requests must pass this check locally before pushing. Use `helm template . --values values.yaml` to render manifests for review. For a dry run that mirrors CI, execute `helm install --dry-run --debug universal ./`. Package the chart with `helm package .` when preparing a tagged release (`v*.*.*`), mirroring the release workflow.

## Coding Style & Naming Conventions
Author manifests in YAML with two-space indentation and keep Helm logic minimal and readable—prefer `include`, `nindent`, and `toYaml` helpers from `_helpers.tpl` for shared labels and nested structures. Name new templates descriptively (for example, `cronjob.yaml`). Avoid embedding secrets; expect operators to override sensitive values externally. Update `Chart.yaml` `version` for any user-visible change.

## Testing Guidelines
Leverage Helm’s built-in test hook at `templates/tests/test-connection.yaml`; ensure it reflects the deployed service contract. Execute `helm lint` for static validation and `helm install --dry-run` for prerender checks. When adding test hooks, follow the `test-<purpose>.yaml` naming pattern and confirm they cleanly uninstall.

## Commit & Pull Request Guidelines
Commits follow short, imperative messages (e.g., “Add GA linter”) and typically group related chart changes with the corresponding `Chart.yaml` bump. Pull requests should explain the motivation, list key value defaults touched, and note any Kubernetes API changes. Link tracking issues when applicable and include `helm template` output snippets or screenshots if behavior changes surface resources or annotations.

## Security & Configuration Tips
Do not commit environment-specific overrides; keep custom values in separate files ignored by Git. Prefer referencing existing `values.yaml` knobs before introducing new ones, and document any new configuration in the PR description.
