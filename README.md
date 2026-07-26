# Community Opencloud Helm Chart

Welcome to the **Opencloud Helm Chart** repository! This repository is intended as a community-driven space for developing and maintaining Helm charts for deploying OpenCloud on Kubernetes.
**Community Maintained** This repository is **community-maintained** and **not officially supported by OpenCloud GmbH**. Use at your own risk, and feel free to contribute to improve the project!

## 📑 Table of Contents

- [About](#-about)
- [Version table](#-version-table)
- [Contributing](#-contributing)
- [Prerequisites](#prerequisites)
- [Available Charts](#-available-charts)
  - [Production Chart](#production-chart-chartsopencloud)
- [License](#-license)
- [Quick Start](#-quick-start)

## 🚀 About

This repository is created to **welcome contributions from the community**. It does not contain official charts from OpenCloud GmbH and is **not officially supported by OpenCloud GmbH**. Instead, these charts are maintained by the open-source community.

OpenCloud is a cloud collaboration platform that provides file sync and share, document collaboration, and more. This Helm chart deploys OpenCloud with the **integrated identity manager (IDM)** by default — no external Keycloak, PostgreSQL, or MinIO required. Collabora (document editing) is bundled. Optionally, external OIDC (Keycloak, Auth0, etc.), external S3 storage, and ClamAV virus scanning can be configured.

## 🚀 Version table

| OpenCloud Version | Helm Chart Version |
|-------------------|--------|
| 4.1.0            | 0.2.4, 0.3.0 |
| 5.0.0            | 0.4.0 |
| 5.0.1            | 1.0.0 |
| 5.0.2            | 0.4.1, 1.0.1|
| 5.1.0            | 2.0.0 |
| 5.2.0            | 2.0.1 |
| 6.0.0            | 2.1.0 |
| 6.1.0            | 2.2.0 |
| 6.2.0            | 2.3.0 |
| 7.0.0            | 2.4.0, 2.4.1, 2.4.2 |
| 7.1.0            | 2.4.3 |
| 7.2.0            | 2.4.4 |
| 7.3.0            | 2.4.5, 2.4.6 |


## 💡 Contributing

We encourage contributions from the community! This repository follows a community-driven development model with defined roles and responsibilities.

For detailed contribution guidelines, please see our [CONTRIBUTING.md](./CONTRIBUTING.md) document.

This includes:
- How to submit contributions
- Our community governance model

## Prerequisites

- Kubernetes 1.33+
- Helm 3.18.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)
- Gateway API compatible ingress controller (e.g., Cilium Gateway) for HTTPS routing

## 📦 Available Charts

This repository contains the following charts:

### Production Chart (`charts/opencloud`)

The complete OpenCloud deployment:

- OpenCloud with integrated IDM (default) or external OIDC
- Collabora for document editing
- PVC-backed storage (posixfs/decomposed) or external S3
- Optional: ClamAV virus scanning, OPA policies, external LDAP user management

[View Production Chart Documentation](./charts/opencloud/README.md)

## 📜 License

This project is licensed under the **AGPLv3** license. See the [LICENSE](LICENSE) file for more details.

## ⚡ Quick Start

Deploy OpenCloud with the integrated IDM (no external Keycloak, PostgreSQL, or MinIO) in a single `helm install`. Works out of the box with a Gateway API-compatible ingress controller (e.g., Cilium Gateway).

```bash
# Navigate to the chart directory first
cd /path/to/helm-repo/charts/opencloud

# Then run the installation command
helm install opencloud . \
  --namespace opencloud \
  --create-namespace \
  --set httpRoute.enabled=true \
  --set httpRoute.gateway.name=cilium-gateway \
  --set httpRoute.gateway.namespace=kube-system \
  --set httpRoute.gateway.sectionName=opencloud
```

Verify the deployment:

```bash
kubectl get pods -n opencloud
```

Uninstall (PVCs are retained by Helm to preserve data — delete them manually if you want a clean slate):

```bash
helm uninstall opencloud -n opencloud
# Optional: drop retained PVCs
kubectl -n opencloud delete pvc -l app.kubernetes.io/instance=opencloud
```

> **Note:** Never delete the namespace — only use `helm uninstall` (or delete the HelmRelease if using Flux). This ensures PVCs always stay.

For deploying the full stack with FluxCD (external Keycloak, OpenLDAP, ClamAV), see the [chart documentation](./charts/opencloud/README.md) — self-contained HelmReleases live in `charts/opencloud/deployments/flux/`.
