# livepeer-gateway

Helm chart for deploying a [Livepeer](https://livepeer.org/) gateway using the `go-livepeer` image. Supports **singleton** and **distributed** deployment modes with optional remote signer integration.

## Modes

### Singleton

A single StatefulSet where the remote signer (if enabled) runs as a **sidecar container** in the same pod, bound to `127.0.0.1`. Suitable for simple or dev deployments.

### Distributed

The gateway StatefulSet runs independently. When remote signing is enabled, a separate stateless **Deployment** handles Ethereum operations, reachable via a cluster-internal Service. Recommended for production workloads that require independent scaling and isolation.

## Remote Signer

The remote signer separates Ethereum key custody from media processing ([docs](https://github.com/livepeer/go-livepeer/blob/master/doc/remote-signer.md)).

When `remoteSigner.enabled=true`:

- **Gateway** runs in offchain mode. Ethereum/payment flags are automatically omitted from gateway args and `-remoteSignerUrl` is injected pointing at the chart-derived cluster-local service URL.
- **Remote signer** must be configured with on-chain network flags, ETH URL, and wallet/passphrase material via `remoteSigner.args` and `remoteSigner.env`.
- PM/pricing configuration (`-maxTicketEV`, `-maxPricePerUnit`, etc.) belongs on the remote signer side.

The remote signer is stateless and should be kept on a private network. The chart defaults to `remoteSigner.service.type: ClusterIP` and `remoteSigner.ingress.enabled: false`.

The gateway fails fast at startup if the signer URL is unreachable.

## Per-Replica Ingress

The gateway is a StatefulSet. Each replica can be individually addressed:

- `gateway.service.perReplica.enabled`: creates a ClusterIP Service per pod (selector: `statefulset.kubernetes.io/pod-name`).
- `gateway.ingress.perReplica.enabled`: creates an Ingress per replica routing to its matching per-replica Service.
- `gateway.ingress.perReplica.hostTemplate`: hostname pattern. Use `${INDEX}` for the replica index and `${FULLNAME}` for the release fullname.

Example:

```yaml
gateway:
  replicaCount: 3
  service:
    perReplica:
      enabled: true
  ingress:
    perReplica:
      enabled: true
      hostTemplate: "gw-${INDEX}.example.com"
```

This renders 3 Ingress objects (`gw-0.example.com`, `gw-1.example.com`, `gw-2.example.com`), each routing to the corresponding per-replica Service.

## Installation

```bash
helm dependency build
helm install my-gateway ./charts/livepeer-gateway -f values.yaml
```

### Singleton with remote signer

```bash
helm install my-gateway ./charts/livepeer-gateway \
  -f charts/livepeer-gateway/examples/values.singleton.yaml
```

### Distributed with remote signer

```bash
helm install my-gateway ./charts/livepeer-gateway \
  -f charts/livepeer-gateway/examples/values.distributed.yaml
```

## Key Values

| Key | Default | Description |
|-----|---------|-------------|
| `gateway.mode` | `singleton` | Deployment mode: `singleton` or `distributed` |
| `gateway.replicaCount` | `1` | Number of gateway replicas |
| `gateway.args` | `["-gateway"]` | CLI args for the gateway container |
| `gateway.service.perReplica.enabled` | `false` | Create per-replica Services |
| `gateway.ingress.perReplica.enabled` | `false` | Create per-replica Ingress objects |
| `gateway.ingress.perReplica.hostTemplate` | `""` | Hostname pattern (`${INDEX}`, `${FULLNAME}`) |
| `remoteSigner.enabled` | `false` | Enable remote signer |
| `remoteSigner.httpPort` | `7936` | Remote signer HTTP port |
| `remoteSigner.args` | `[]` | CLI args for the remote signer |
| `remoteSigner.service.enabled` | `true` | Create Service for remote signer (distributed) |
| `remoteSigner.ingress.enabled` | `false` | Expose remote signer via Ingress |

See [`values.yaml`](values.yaml) for the full contract.

## Chart Design

This chart follows a **hybrid Stakater-inspired** structure:

- Common helpers live in `livepeer-common` (library chart): naming, labels, image rendering, probes, pod scheduling.
- Gateway-specific logic (mode validation, arg filtering, signer URL derivation) lives in local partials (`_mode.tpl`, `_gateway-workload.tpl`, `_remote-signer.tpl`).
- Standard Helm toggles (`*.enabled`, `*.annotations`, `*.labels`) follow conventions from [stakater/application](https://github.com/stakater/application).
