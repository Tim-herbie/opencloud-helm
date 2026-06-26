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

OpenCloud is a cloud collaboration platform that provides file sync and share, document collaboration, and more. This Helm chart deploys OpenCloud with Keycloak for authentication, OpenLDAP for user management, ClamAV for virus scanning, and Collabora for document editing.

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

The complete OpenCloud deployment with all components for production use:

- Full microservices architecture
- Keycloak for OIDC authentication
- OpenLDAP for user directory
- ClamAV for virus scanning
- Document editing with Collabora
- OPA policies for file type restrictions

[View Production Chart Documentation](./charts/opencloud/README.md)

## 📜 License

This project is licensed under the **AGPLv3** license. See the [LICENSE](LICENSE) file for more details.

## ⚡ Quick Start

Deploy the full stack (Keycloak + PostgreSQL, OpenLDAP, ClamAV, OpenCloud, Collabora) with a single CLI command. Each manifest in `charts/opencloud/deployments/flux/` is self-contained (inline database config, realm import, HTTPRoutes, HTTP→HTTPS redirects) — no Helmfile or Timoni bundle required.

1. **Deploy the full stack:**
   ```sh
   kubectl apply -R -f charts/opencloud/deployments/flux/
   ```

   `-R` recurses into the `flux/` subdirectories (`keycloak/`, `openldap/`, `clamav/`, `opencloud/`) and applies every `*.yaml` in one shot. Each `HelmRelease` is then reconciled by FluxCD's `helm-controller`.

2. **Verify the deployment:**
   ```sh
   kubectl get pods -A | grep -E "opencloud|keycloak|openldap|clamav"
   ```

3. **Reconcile after a change** (edit a value, bump the chart, etc.):
   ```sh
   for hr in $(kubectl get hr -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{" "}{end}'); do flux reconcile helmrelease "$(echo $hr | cut -d/ -f2)" -n "$(echo $hr | cut -d/ -f1)"; done
   ```

4. **Remove the full stack** (one command — drops all HelmReleases, HelmRepositories, OCIRepositories, Secrets, ConfigMaps, and the namespaces; PVCs are retained by default, delete them manually if you want a clean slate):
   ```sh
   kubectl delete -R -f charts/opencloud/deployments/flux/
   kubectl delete ns opencloud keycloak openldap clamav
   ```
