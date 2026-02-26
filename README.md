# livepeer-charts

Helm charts for [Livepeer](https://livepeer.org/) infrastructure. All role charts share a single `go-livepeer` Docker image and a common library chart for template reuse.

## Charts

| Chart | Type | Description |
|-------|------|-------------|
| [livepeer-common](charts/livepeer-common/) | Library | Shared helpers for naming, labels, image rendering, probes, and pod scheduling |
| [livepeer-gateway](charts/livepeer-gateway/) | Application | Gateway with singleton/distributed modes and optional remote signer |

## Architecture

```
livepeer-charts/
  charts/
    livepeer-common/       # library chart (non-deployable)
    livepeer-gateway/      # deployable gateway chart
    livepeer-broadcaster/  # (planned)
    livepeer-orchestrator/ # (planned)
```

Each deployable chart depends on `livepeer-common` for shared template functions. Role-specific behavior stays in its own chart.

## Quick Start

```bash
cd charts/livepeer-gateway
helm dependency build
helm install my-gateway . -f examples/values.singleton.yaml
```

## Adding a New Role Chart

1. Create `charts/livepeer-<role>/` with standard Helm structure.
2. Add `livepeer-common` as a dependency in `Chart.yaml`:
   ```yaml
   dependencies:
     - name: livepeer-common
       version: 0.1.0
       repository: file://../livepeer-common
   ```
3. Use `livepeer-common.*` helpers for naming, labels, image rendering, probes, and scheduling.
4. Keep role-specific templates and values local to the new chart.
5. Add the chart to CI in `.github/workflows/helm-ci.yaml`.

## Development

### Lint

```bash
helm lint charts/livepeer-gateway
```

### Template

```bash
helm template test charts/livepeer-gateway -f charts/livepeer-gateway/examples/values.singleton.yaml
```
