# Timoni Bundles for OpenCloud (FluxCD)

This directory contains Timoni bundles for deploying OpenCloud and its dependencies via FluxCD.

## Bundles

| Bundle | Description | Namespace |
|--------|-------------|-----------|
| `opencloud` | OpenCloud monolithic chart | `opencloud` |
| `openldap` | osixia/openldap with custom schema | `openldap` |
| `clamav` | wiremind/clamav antivirus scanner | `clamav` |

## Install/Upgrade

### 1. Install OpenLDAP (first)
```bash
kubectl apply -f ./charts/opencloud/deployments/timoni/openldap && \
timoni bundle apply -f ./charts/opencloud/deployments/timoni/openldap/openldap.cue \
  --runtime ./charts/opencloud/deployments/timoni/openldap/runtime.cue
```

### 2. Install ClamAV (optional)
```bash
kubectl apply -f ./charts/opencloud/deployments/timoni/clamav && \
timoni bundle apply -f ./charts/opencloud/deployments/timoni/clamav/clamav.cue \
  --runtime ./charts/opencloud/deployments/timoni/clamav/runtime.cue
```

### 3. Install OpenCloud
```bash
kubectl apply -f ./charts/opencloud/deployments/timoni/opencloud && \
timoni bundle apply -f ./charts/opencloud/deployments/timoni/opencloud/opencloud.cue \
  --runtime ./charts/opencloud/deployments/timoni/opencloud/runtime.cue
```

## Prerequisites

- [Timoni CLI](https://timoni.sh/installation/)
- [FluxCD](https://fluxcd.io/docs/installation/) installed on the cluster
- Kubernetes cluster with Gateway API support (for HTTPRoute)

## Configuration

Each bundle has its own `runtime.cue` file with default values that can be overridden
via Kubernetes ConfigMaps and Secrets. See each bundle's README for details.
