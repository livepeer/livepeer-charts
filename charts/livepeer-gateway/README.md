# livepeer-gateway

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=for-the-badge) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=for-the-badge) ![AppVersion: v0.8.9](https://img.shields.io/badge/AppVersion-v0.8.9-informational?style=for-the-badge)

Helm chart for deploying a [Livepeer](https://livepeer.org/) gateway using the `go-livepeer` image. Supports **singleton** and **distributed** deployment modes with optional remote signer integration.
**Homepage:** <https://charts.livepeer.org/>

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

Charts are published to [charts.livepeer.org](https://charts.livepeer.org):

```bash
helm repo add livepeer https://charts.livepeer.org
helm repo update
helm install my-gateway livepeer/livepeer-gateway -f values.yaml
```

### Singleton with remote signer

```bash
helm install my-gateway livepeer/livepeer-gateway \
  -f examples/values.singleton.yaml
```

### Distributed with remote signer

```bash
helm install my-gateway livepeer/livepeer-gateway \
  -f examples/values.distributed.yaml
```

### From source

```bash
cd charts/livepeer-gateway
helm dependency build
helm install my-gateway . -f values.yaml
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` |  |
| gateway.affinity | object | `{}` |  |
| gateway.annotations | object | `{}` |  |
| gateway.args[0] | string | `"-gateway"` |  |
| gateway.autoscaling.enabled | bool | `false` |  |
| gateway.autoscaling.maxReplicas | int | `10` |  |
| gateway.autoscaling.metrics[0].resource.name | string | `"cpu"` |  |
| gateway.autoscaling.metrics[0].resource.target.averageUtilization | int | `60` |  |
| gateway.autoscaling.metrics[0].resource.target.type | string | `"Utilization"` |  |
| gateway.autoscaling.metrics[0].type | string | `"Resource"` |  |
| gateway.autoscaling.minReplicas | int | `1` |  |
| gateway.command[0] | string | `"livepeer"` |  |
| gateway.env | object | `{}` |  |
| gateway.ingress.annotations | object | `{}` |  |
| gateway.ingress.className | string | `""` |  |
| gateway.ingress.enabled | bool | `false` |  |
| gateway.ingress.hosts | list | `[]` |  |
| gateway.ingress.perReplica.annotations | object | `{}` |  |
| gateway.ingress.perReplica.enabled | bool | `false` |  |
| gateway.ingress.perReplica.hostTemplate | string | `""` |  |
| gateway.ingress.perReplica.paths | list | `[]` |  |
| gateway.ingress.perReplica.tls | list | `[]` |  |
| gateway.ingress.tls | list | `[]` |  |
| gateway.labels | object | `{}` |  |
| gateway.livenessProbe.enabled | bool | `true` |  |
| gateway.livenessProbe.failureThreshold | int | `6` |  |
| gateway.livenessProbe.httpGet.path | string | `"/status"` |  |
| gateway.livenessProbe.httpGet.port | string | `"http-cli"` |  |
| gateway.mode | string | `"singleton"` |  |
| gateway.nodeSelector | object | `{}` |  |
| gateway.podAnnotations | object | `{}` |  |
| gateway.podLabels | object | `{}` |  |
| gateway.ports[0].containerPort | int | `8935` |  |
| gateway.ports[0].name | string | `"http-video"` |  |
| gateway.ports[0].protocol | string | `"TCP"` |  |
| gateway.ports[1].containerPort | int | `7935` |  |
| gateway.ports[1].name | string | `"http-cli"` |  |
| gateway.ports[1].protocol | string | `"TCP"` |  |
| gateway.ports[2].containerPort | int | `1935` |  |
| gateway.ports[2].name | string | `"rtmp"` |  |
| gateway.ports[2].protocol | string | `"TCP"` |  |
| gateway.readinessProbe.enabled | bool | `true` |  |
| gateway.readinessProbe.failureThreshold | int | `3` |  |
| gateway.readinessProbe.httpGet.path | string | `"/status"` |  |
| gateway.readinessProbe.httpGet.port | string | `"http-cli"` |  |
| gateway.readinessProbe.timeoutSeconds | int | `8` |  |
| gateway.replicaCount | int | `1` |  |
| gateway.resources | object | `{}` |  |
| gateway.service.annotations | object | `{}` |  |
| gateway.service.enabled | bool | `true` |  |
| gateway.service.perReplica.annotations | object | `{}` |  |
| gateway.service.perReplica.enabled | bool | `false` |  |
| gateway.service.ports[0].name | string | `"http-video"` |  |
| gateway.service.ports[0].port | int | `80` |  |
| gateway.service.ports[0].protocol | string | `"TCP"` |  |
| gateway.service.ports[0].targetPort | int | `8935` |  |
| gateway.service.ports[1].name | string | `"http-cli"` |  |
| gateway.service.ports[1].port | int | `7935` |  |
| gateway.service.ports[1].protocol | string | `"TCP"` |  |
| gateway.service.ports[1].targetPort | int | `7935` |  |
| gateway.service.type | string | `"ClusterIP"` |  |
| gateway.startupProbe.enabled | bool | `true` |  |
| gateway.startupProbe.failureThreshold | int | `60` |  |
| gateway.startupProbe.httpGet.path | string | `"/status"` |  |
| gateway.startupProbe.httpGet.port | string | `"http-cli"` |  |
| gateway.startupProbe.periodSeconds | int | `10` |  |
| gateway.startupProbe.successThreshold | int | `1` |  |
| gateway.startupProbe.timeoutSeconds | int | `3` |  |
| gateway.strategy.rollingUpdate.maxSurge | int | `1` |  |
| gateway.strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| gateway.strategy.type | string | `"RollingUpdate"` |  |
| gateway.tolerations | list | `[]` |  |
| gateway.volumeMounts | list | `[]` |  |
| gateway.volumes | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"livepeer/go-livepeer"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| remoteSigner.affinity | object | `{}` |  |
| remoteSigner.annotations | object | `{}` |  |
| remoteSigner.args | list | `[]` |  |
| remoteSigner.autoscaling.enabled | bool | `false` |  |
| remoteSigner.autoscaling.maxReplicas | int | `3` |  |
| remoteSigner.autoscaling.metrics[0].resource.name | string | `"cpu"` |  |
| remoteSigner.autoscaling.metrics[0].resource.target.averageUtilization | int | `60` |  |
| remoteSigner.autoscaling.metrics[0].resource.target.type | string | `"Utilization"` |  |
| remoteSigner.autoscaling.metrics[0].type | string | `"Resource"` |  |
| remoteSigner.autoscaling.minReplicas | int | `1` |  |
| remoteSigner.command[0] | string | `"livepeer"` |  |
| remoteSigner.enabled | bool | `false` |  |
| remoteSigner.env | object | `{}` |  |
| remoteSigner.httpPort | int | `7936` |  |
| remoteSigner.image.pullPolicy | string | `"IfNotPresent"` |  |
| remoteSigner.image.repository | string | `"livepeer/go-livepeer"` |  |
| remoteSigner.image.tag | string | `""` |  |
| remoteSigner.ingress.annotations | object | `{}` |  |
| remoteSigner.ingress.className | string | `""` |  |
| remoteSigner.ingress.enabled | bool | `false` |  |
| remoteSigner.ingress.hosts | list | `[]` |  |
| remoteSigner.ingress.tls | list | `[]` |  |
| remoteSigner.labels | object | `{}` |  |
| remoteSigner.nodeSelector | object | `{}` |  |
| remoteSigner.podAnnotations | object | `{}` |  |
| remoteSigner.podLabels | object | `{}` |  |
| remoteSigner.resources | object | `{}` |  |
| remoteSigner.service.annotations | object | `{}` |  |
| remoteSigner.service.enabled | bool | `true` |  |
| remoteSigner.service.ports[0].name | string | `"signer-http"` |  |
| remoteSigner.service.ports[0].port | int | `7936` |  |
| remoteSigner.service.ports[0].protocol | string | `"TCP"` |  |
| remoteSigner.service.ports[0].targetPort | int | `7936` |  |
| remoteSigner.service.type | string | `"ClusterIP"` |  |
| remoteSigner.tolerations | list | `[]` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |

See [`values.yaml`](values.yaml) for the full contract.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Livepeer | <support@livepeer.org> | <https://github.com/livepeer> |
| hjpotter92 |  | <https://github.com/hjpotter92> |

## Chart Design

This chart follows a **hybrid Stakater-inspired** structure:

- Common helpers live in `livepeer-common` (library chart): naming, labels, image rendering, probes, pod scheduling.
- Gateway-specific logic (mode validation, arg filtering, signer URL derivation) lives in local partials (`_mode.tpl`, `_gateway-workload.tpl`, `_remote-signer.tpl`).
- Standard Helm toggles (`*.enabled`, `*.annotations`, `*.labels`) follow conventions from [stakater/application](https://github.com/stakater/application).

## Source Code

* <https://github.com/livepeer/livepeer-charts>
* <https://github.com/livepeer/livepeer-charts/blob/main/charts/livepeer-gateway/README.md>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../livepeer-common | livepeer-common | 1.0.0 |

## Readme template

The chart README is generated from the [README.md.gotmpl](README.md.gotmpl) template. To update the README, edit the template and run following command to generate the new README.md file.

```bash
helm-docs --skip-version-footer --document-dependency-values --badge-style for-the-badge
```
