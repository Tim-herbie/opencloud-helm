<img src="https://helm.sh/img/helm.svg" width="100px" heigth="100px">

# OpenCloud Helm Charts

Welcome to the **OpenCloud Helm Charts** repository! This repository is intended as a community-driven space for developing and maintaining Helm charts for deploying OpenCloud on Kubernetes.

## 📑 Table of Contents

- [About](#-about)
- [Community](#-community)
- [Contributing](#-contributing)
- [Prerequisites](#prerequisites)
- [Installing the Helm Charts](#-installing-the-helm-charts)
- [Architecture](#architecture)
  - [Component Interaction Diagram](#component-interaction-diagram)
- [Configuration](#configuration)
  - [Global Settings](#global-settings)
  - [Image Settings](#image-settings)
  - [OpenCloud Settings](#opencloud-settings)
  - [Keycloak Settings](#keycloak-settings)
  - [PostgreSQL Settings](#postgresql-settings)
  - [Collabora Settings](#collabora-settings)
  - [Collaboration Service Settings](#collaboration-service-settings)
- [Gateway API Configuration](#gateway-api-configuration)
  - [HTTPRoute Settings](#httproute-settings)
- [Setting Up Gateway API with Talos, Cilium, and cert-manager](#setting-up-gateway-api-with-talos-cilium-and-cert-manager)
- [Development Chart](#-development-chart)
- [License](#-license)
- [Community Maintained](#community-maintained)

## 🚀 About

This repository is created to **welcome contributions from the community**. It does not contain official charts from OpenCloud GmbH and is **not officially supported by OpenCloud GmbH**. Instead, these charts are maintained by the open-source community.

OpenCloud is a cloud collaboration platform that provides file sync and share, document collaboration, and more. This Helm chart deploys OpenCloud with Keycloak for authentication, MinIO for object storage, and options for document editing with Collabora.

## 💬 Community

Join our Matrix chat for discussions about OpenCloud Helm Charts:
- [OpenCloud Helm on Matrix](https://matrix.to/#/%23opencloud-helm:matrix.org)

For general OpenCloud discussions:
- [OpenCloud on Matrix](https://matrix.to/#/%23opencloud:matrix.org)
- [OpenCloud on Mastodon](https://social.opencloud.eu/@OpenCloud)
- [GitHub Discussions](https://github.com/orgs/opencloud-eu/discussions)

## 💡 Contributing

We encourage contributions from the community! If you'd like to contribute:
- Fork this repository
- Submit a Pull Request
- Discuss and collaborate on issues

Please ensure that your PR follows best practices and includes necessary documentation.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)
- External ingress controller (e.g., Cilium Gateway API) for routing traffic to the services

## 📦 Installation

To install the chart with the release name `opencloud`:

```bash
# Navigate to the chart directory first
cd /path/to/helm-repo/charts/opencloud

# Then run the installation command
helm install opencloud . \
  --namespace opencloud \
  --create-namespace \
  --set httpRoute.enabled=true \
  --set httpRoute.gateway.name=opencloud-gateway \
  --set httpRoute.gateway.namespace=kube-system
```

Alternatively, from the repository root:

```bash
helm install opencloud ./charts/opencloud \
  --namespace opencloud \
  --create-namespace \
  --set httpRoute.enabled=true \
  --set httpRoute.gateway.name=opencloud-gateway \
  --set httpRoute.gateway.namespace=kube-system
```

## Architecture

This Helm chart deploys the following components:

1. **OpenCloud** - Main application (fork of ownCloud Infinite Scale)
2. **Keycloak** - Authentication provider with OpenID Connect
3. **PostgreSQL** - Database for Keycloak
4. **MinIO** - S3-compatible object storage
5. **Collabora** - Online document editor (CODE - Collabora Online Development Edition)
6. **Collaboration Service** - WOPI server that connects OpenCloud with document editors

All services are deployed with `ClusterIP` type, which means they are only accessible within the Kubernetes cluster. You need to configure your own ingress controller (e.g., Cilium Gateway API) to expose the services externally.

### Component Interaction Diagram

The following diagram shows how the different components interact with each other:

```mermaid
graph TD
    User[User Browser] -->|Accesses| Gateway[Gateway API]
    
    subgraph "OpenCloud System"
        Gateway -->|cloud.opencloud.test| OpenCloud[OpenCloud Pod]
        Gateway -->|collabora.opencloud.test| Collabora[Collabora Pod]
        Gateway -->|collaboration.opencloud.test| Collaboration[Collaboration Pod]
        Gateway -->|wopiserver.opencloud.test| Collaboration
        Gateway -->|keycloak.opencloud.test| Keycloak[Keycloak Pod]
        Gateway -->|minio.opencloud.test| MinIO[MinIO Pod]
        
        OpenCloud -->|Authentication| Keycloak
        OpenCloud -->|File Storage| MinIO
        
        Collabora -->|WOPI Protocol| Collaboration
        Collaboration -->|File Access| MinIO
        
        Collaboration -->|Authentication| Keycloak
        
        OpenCloud -->|Collaboration API| Collaboration
    end
    
    classDef pod fill:#f9f,stroke:#333,stroke-width:2px;
    classDef gateway fill:#bbf,stroke:#333,stroke-width:2px;
    classDef user fill:#bfb,stroke:#333,stroke-width:2px;
    classDef db fill:#dfd,stroke:#333,stroke-width:2px;
    
    class OpenCloud,Collabora,Collaboration,Keycloak,MinIO pod;
    class PostgreSQL,Redis db;
    class Gateway gateway;
    class User user;
```

Key interactions:

1. **User to Gateway**: 
   - Users access all services through the Gateway API using different hostnames

2. **OpenCloud Pod**:
   - Main application that users interact with
   - Authenticates users via Keycloak
   - Stores files in MinIO
   - Communicates with Collaboration service for collaborative editing

3. **Collabora Pod**:
   - Office document editor
   - Connects to the Collaboration pod via WOPI protocol
   - Uses token server secret for authentication

4. **Collaboration Pod**:
   - Implements WOPI server functionality
   - Acts as intermediary between document editors and file storage
   - Handles collaborative editing sessions
   - Accesses files from MinIO

5. **Keycloak Pod**:
   - Handles authentication for all services
   - Manages user identities and permissions

6. **MinIO Pod**:
   - Object storage for all files
   - Accessed by OpenCloud and Collaboration pods

## Configuration

The following table lists the configurable parameters of the OpenCloud chart and their default values.

### Using Private Registries

The chart supports using private container registries through global overrides. This is useful for:
- Air-gapped environments
- Corporate registry mirrors
- Pull-through caches

To use a private registry for all images:

```bash
helm install opencloud ./charts/opencloud \
  --set global.image.registry=my-registry.com \
  --set global.image.pullPolicy=Always
```

This will prepend `my-registry.com/` to all image references in the chart. For example:
- `keycloak/keycloak:26.1.4` becomes `my-registry.com/keycloak/keycloak:26.1.4`
- `opencloudeu/opencloud-rolling:latest` becomes `my-registry.com/opencloudeu/opencloud-rolling:latest`

### Global Settings

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `namespace` | Deprecated: Namespace is now controlled by Helm (.Release.Namespace) | (removed) |
| `global.domain.opencloud` | Domain for OpenCloud | `cloud.opencloud.test` |
| `global.domain.oidc` | Domain for Keycloak/OIDC provider | `keycloak.opencloud.test` |
| `global.domain.minio` | Domain for MinIO | `minio.opencloud.test` |
| `global.domain.collabora` | Domain for Collabora | `collabora.opencloud.test` |
| `global.domain.companion` | Domain for Companion | `companion.opencloud.test` |
| `global.domain.wopi` | Domain for WOPI server | `wopiserver.opencloud.test` |
| `global.tls.enabled` | Enable TLS (set to false when using gateway TLS termination externally) | `false` |
| `global.tls.secretName` | secretName for TLS certificate | `""` |
| `global.storage.storageClass` | Storage class for persistent volumes | `""` |
| `global.image.registry` | Global registry override for all images (e.g., `my-registry.com`) | `""` |
| `global.image.pullPolicy` | Global pull policy override for all images (`Always`, `IfNotPresent`, `Never`) | `""` |

### Image Settings

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `image.registry` | OpenCloud image registry | `docker.io` |
| `image.repository` | OpenCloud image repository | `opencloudeu/opencloud-rolling` |
| `image.tag` | OpenCloud image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.pullSecrets` | Image pull secrets | `[]` |

### OpenCloud Settings

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `opencloud.enabled` | Enable OpenCloud | `true` |
| `opencloud.replicas` | Number of replicas (Note: When using multiple replicas, persistence should be disabled or use a storage class that supports ReadWriteMany access mode) | `1` |
| `opencloud.logLevel` | Log level | `info` |
| `opencloud.logColor` | Enable log color | `false` |
| `opencloud.logPretty` | Enable pretty logging | `false` |
| `opencloud.insecure` | Insecure mode (for self-signed certificates) | `true` |
| `opencloud.existingSecret` | Name of the existing secret | `` |
| `opencloud.adminPassword` | Admin password | `admin` |
| `opencloud.createDemoUsers` | Create demo users | `false` |
| `opencloud.resources` | CPU/Memory resource requests/limits | `{}` |
| `opencloud.persistence.enabled` | Enable persistence | `true` |
| `opencloud.persistence.size` | Size of the persistent volume | `10Gi` |
| `opencloud.persistence.storageClass` | Storage class | `""` |
| `opencloud.persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `opencloud.smtp.enabled` | Enable smtp for opencloud | `false` |
| `opencloud.smtp.host` | SMTP host | `` |
| `opencloud.smtp.port` | SMTP port | `587` |
| `opencloud.smtp.sender` | SMTP sender | `` |
| `opencloud.smtp.existingSecret` | Name of the existing secret | `` |
| `opencloud.smtp.username` | SMTP username | `` |
| `opencloud.smtp.password` | SMTP password | `` |
| `opencloud.smtp.insecure` | SMTP insecure | `false` |
| `opencloud.smtp.authentication` | SMTP authentication | `plain` |
| `opencloud.smtp.encryption` | SMTP encryption | `starttls` |
| `opencloud.storage.mode` | Choice between s3 and posixfs for user files | `s3` |

### OpenCloud S3 Storage Settings

The following options configure S3 for user file storage, either with the internal MinIO instance or with an external S3 provider.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `opencloud.storage.s3.enabled` | Enable internal MinIO instance | `true` |
| `opencloud.storage.s3.image.registry` | MinIO image registry | `docker.io` |
| `opencloud.storage.s3.image.repository` | MinIO image repository | `minio/minio` |
| `opencloud.storage.s3.image.tag` | MinIO image tag | `latest` |
| `opencloud.storage.s3.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `opencloud.storage.s3.httpRoute.enabled` | Enable HTTPRoute for MinIO | `false` |
| `opencloud.storage.s3.existingSecret` | Name of the existing secret | `` |
| `opencloud.storage.s3.rootUser` | MinIO root user | `opencloud` |
| `opencloud.storage.s3.rootPassword` | MinIO root password | `opencloud-secret-key` |
| `opencloud.storage.s3.bucketName` | MinIO bucket name | `opencloud-bucket` |
| `opencloud.storage.s3.region` | MinIO region | `default` |
| `opencloud.storage.s3.resources` | CPU/Memory resource requests/limits | See values.yaml |
| `opencloud.storage.s3.persistence.enabled` | Enable MinIO persistence | `true` |
| `opencloud.storage.s3.persistence.existingClaim` | Name of existing PVC instead of the settings below | `` |
| `opencloud.storage.s3.persistence.size` | Size of the MinIO persistent volume | `30Gi` |
| `opencloud.storage.s3.persistence.storageClass` | MinIO storage class | `""` |
| `opencloud.storage.s3.persistence.accessMode` | MinIO access mode | `ReadWriteOnce` |
| `opencloud.storage.s3.external.endpoint` | External S3 endpoint URL | `""` |
| `opencloud.storage.s3.external.region` | External S3 region | `default` |
| `opencloud.storage.s3.external.existingSecret` | Name of the existing secret | `` |
| `opencloud.storage.s3.external.accessKey` | External S3 access key | `""` |
| `opencloud.storage.s3.external.secretKey` | External S3 secret key | `""` |
| `opencloud.storage.s3.external.bucket` | External S3 bucket | `""` |
| `opencloud.storage.s3.external.createBucket` | Create bucket if it doesn't exist | `true` |

**Note:**  
- The `internal` key under `storage.s3` has been removed. All MinIO/internal S3 settings are now directly under `storage.s3`.
- The `enabled` field under `storage.s3.external` has been removed. To use external S3, set the `endpoint` and other required fields.

### OpenCloud PosixFS Storage Settings

The following options allow setting up a POSIX-compatible filesystem (such as NFS or CephFS) for user file storage instead of S3. This is useful for environments where object storage is not available or not desired.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `opencloud.storage.posixfs.idCacheStore` | Cache store, between 'memory', 'redis-sentinel', 'nats-js-kv', 'noop' | `nats-js-kv` |
| `opencloud.storage.posixfs.rootPath` | Path of storage root directory in openCloud pod | `/var/lib/opencloud/storage` |
| `opencloud.storage.posixfs.persistence.enabled` | Enable persistence for PosixFS | `true` |
| `opencloud.storage.posixfs.persistence.existingClaim` | Name of existing PVC instead of the settings below | `""` |
| `opencloud.storage.posixfs.persistence.size` | Size of the PosixFS persistent volume | `30Gi` |
| `opencloud.storage.posixfs.persistence.storageClass` | Storage class for PosixFS volume | `""` |
| `opencloud.storage.posixfs.persistence.accessMode` | Access mode for PosixFS volume | `ReadWriteMany` |

**Note:** When using `posixfs` mode, ensure that the underlying storage supports the required access mode (e.g., `ReadWriteMany` for multiple replicas). The underlying filesystem must support `flock` and `xattrs` so for NFS the minimum version is 4.2.

### NATS Messaging Configuration

| Parameter  | Description | Default |
| ---------- | ----------- | ------- |
| `opencloud.nats.external.enabled` | Use an external NATS server (required for high availability) | `false` |
| `opencloud.nats.external.endpoint` | Endpoint of the external NATS server | `nats.opencloud-nats.svc.cluster.local:4222` |
| `opencloud.nats.external.cluster` | NATS cluster name | `opencloud-cluster` |
| `opencloud.nats.external.tls.enabled` | Enable TLS for communication with NATS | `false` |
| `opencloud.nats.external.tls.certTrusted` | Set to `false` if the external NATS server's certificate is not trusted by default (e.g. self-signed) | `true` |
| `opencloud.nats.external.tls.insecure` | Disable certificate validation (not recommended for production) | `false` |
| `opencloud.nats.external.tls.caSecretName` | Name of the Kubernetes Secret containing the CA certificate (only required if `certTrusted` is `false`) | `opencloud-nats-ca` |

> 💡 The secret referenced by `caSecretName` **must contain a key named `ca.crt`** with the root CA certificate used to verify the external NATS server.
> Example:
>
> ```bash
> kubectl create secret generic opencloud-nats-ca \
>   --from-file=ca.crt=./path/to/nats-ca.pem \
>   --namespace your-namespace
> ```

### Keycloak Settings

By default the chart deploys an internal Keycloak. It can be disabled and replaced with an external OIDC provider.

#### Internal Keycloak

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `oidc.enabled` | Enable internal Keycloak deployment | `true` |
| `oidc.image.registry` | Keycloak image registry | `quay.io` |
| `oidc.image.repository` | Keycloak image repository | `keycloak/keycloak` |
| `oidc.image.tag` | Keycloak image tag | `26.5.2` |
| `oidc.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `oidc.replicas` | Number of replicas | `1` |
| `oidc.existingSecret` | Name of the existing secret | `` |
| `oidc.adminUser` | Admin user | `admin` |
| `oidc.adminPassword` | Admin password | `admin` |
| `oidc.realm` | Realm name | `openCloud` |
| `oidc.resources` | CPU/Memory resource requests/limits | `{}` |
| `oidc.cors.enabled` | Enable CORS | `true` |
| `oidc.cors.allowAllOrigins` | Allow all origins | `true` |
| `oidc.cors.origins` | Allowed origins (if `allowAllOrigins` is `false`) | `[]` |
| `oidc.cors.methods` | Allowed HTTP methods | `"GET,POST,PUT,DELETE,OPTIONS"` |
| `oidc.cors.headers` | Allowed headers | `"Origin,Accept,Authorization,Content-Type,Cache-Control"` |
| `oidc.cors.exposedHeaders` | Exposed headers | `"Access-Control-Allow-Origin,Access-Control-Allow-Credentials"` |
| `oidc.cors.allowCredentials` | Allow credentials | `"true"` |
| `oidc.cors.maxAge` | Max age in seconds | `"3600"` |

> **Note**: When using internal Keycloak with multiple OpenCloud replicas (`opencloud.replicas > 1`), you must use an external shared database or LDAP. The embedded IDM does not support replication.

#### External OIDC Provider

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `oidc.enabled` | Deploy internal Keycloak (`true`) or use external OIDC (`false`) | `true` |
| `oidc.external.issuerUrl` | OIDC Issuer URL (e.g., `https://keycloak.example.com/realms/openCloud`) | `""` |
| `oidc.external.clientId` | OIDC Client ID | `"web"` |
| `oidc.external.accountUrl` | Account management URL (optional) | `""` |

#### Example: Using External OIDC Provider

```yaml
oidc:
  enabled: false
  external:
    issuerUrl: "https://keycloak.example.com/realms/openCloud"
    clientId: "opencloud-web"
    accountUrl: "https://keycloak.example.com/realms/openCloud/account"
```

### PostgreSQL Settings

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `postgres.enabled` | Enable PostgreSQL | `true` |
| `postgres.database` | Database name | `keycloak` |
| `postgres.existingSecret` | Name of the existing secret | `` |
| `postgres.user` | Database user | `keycloak` |
| `postgres.password` | Database password | `keycloak` |
| `postgres.resources` | CPU/Memory resource requests/limits | `{}` |
| `postgres.persistence.enabled` | Enable persistence | `true` |
| `postgres.persistence.size` | Size of the persistent volume | `1Gi` |
| `postgres.persistence.storageClass` | Storage class | `""` |
| `postgres.persistence.accessMode` | Access mode | `ReadWriteOnce` |

### Collabora Settings

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `collabora.enabled` | Enable Collabora | `true` |
| `collabora.image.repository` | Collabora image repository | `collabora/code` |
| `collabora.image.tag` | Collabora image tag | `24.04.13.2.1` |
| `collabora.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `collabora.existingSecret` | Name of the existing secret | `` |
| `collabora.admin.username` | Admin username | `admin` |
| `collabora.admin.password` | Admin password | `admin` |
| `collabora.ssl.enabled` | Enable SSL | `true` |
| `collabora.ssl.verification` | SSL verification | `true` |
| `collabora.resources` | CPU/Memory resource requests/limits | `{}` |

### Collaboration Service Settings

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `collaboration.enabled` | Enable collaboration service | `true` |
| `collaboration.resources` | CPU/Memory resource requests/limits | `{}` |

## Ingress Configuration

This chart supports standard Kubernetes Ingress resources for exposing services. For environments requiring specific ingress controller features, annotation presets are available.

### Ingress Settings

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `ingress.enabled` | Enable Ingress resources | `false` |
| `ingress.ingressClassName` | Ingress class name (e.g., nginx, traefik) | `""` |
| `ingress.annotationsPreset` | Preset for ingress controller annotations | `""` |
| `ingress.annotations` | Custom annotations for all ingress resources | `{}` |


## Gateway API Configuration

This chart includes HTTPRoute resources that can be used to expose the OpenCloud, Keycloak, and MinIO services externally. The HTTPRoutes are configured to route traffic to the respective services.

### HTTPRoute Settings

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `httpRoute.enabled` | Enable HTTPRoutes | `true` |
| `httpRoute.gateway.name` | Gateway name | `opencloud-gateway` |
| `httpRoute.gateway.namespace` | Gateway namespace | `""` (defaults to Release.Namespace) |
| `httpRoute.gateway.sectionName` | Gateway section name | `""` (defaults to multiple route-specific section names for the routes listed below) |

The following HTTPRoutes are created when `httpRoute.enabled` is set to `true`:

1. **OpenCloud HTTPRoute**:
   - Hostname: `global.domain.opencloud`
   - Service: `{{ release-name }}-opencloud`
   - Port: 9200
   - Headers: Removes Permissions-Policy header to prevent browser console errors

2. **Keycloak HTTPRoute** (when `oidc.enabled` is `true`):
   - Hostname: `global.domain.oidc`
   - Service: `{{ release-name }}-keycloak`
   - Port: 8080
   - Headers: Adds Permissions-Policy header to prevent browser features like interest-based advertising

3. **MinIO HTTPRoute** (when `opencloud.storage.mode` is `s3` and `opencloud.storage.s3.enabled` is `true`):
   - Hostname: `global.domain.minio`
   - Service: `{{ release-name }}-minio`
   - Port: 9001
   - Headers: Adds Permissions-Policy header to prevent browser features like interest-based advertising

   default user: opencloud
   pass: opencloud-secret-key

4. **Collabora HTTPRoute** (when `collabora.enabled` is `true`):
   - Hostname: `global.domain.collabora`
   - Service: `{{ release-name }}-collabora`
   - Port: 9980
   - Headers: Adds Permissions-Policy header to prevent browser features like interest-based advertising

5. **Collaboration (WOPI) HTTPRoute** (when `collaboration.enabled` is `true`):
   - Hostname: `global.domain.wopi`
   - Service: `{{ release-name }}-collaboration`
   - Port: 9300
   - Headers: Adds Permissions-Policy header to prevent browser features like interest-based advertising

All HTTPRoutes are configured to use the same Gateway specified by `httpRoute.gateway.name` and `httpRoute.gateway.namespace`. If `httpRoute.gateway.sectionName` is set, they also all use a single section (e.g. `https`) in the gateway resource (useful when `httpRoute.gateway.create` is `false` because a gateway already exists). Otherwise, when `httpRoute.gateway.sectionName` is left empty, each route gets its own generated `sectionName` that points to a section in the gateway resource that is automatically set up when `httpRoute.gateway.create` is `true`.

## Setting Up Gateway API with Talos, Cilium, and cert-manager

This section provides a practical guide to setting up the Gateway API with Talos, Cilium, and cert-manager for OpenCloud.

### Prerequisites

- Talos Kubernetes cluster up and running
- kubectl configured to access your cluster
- Helm 3 installed

### Step 1: Install Cilium with Gateway API Support

First, install Cilium with Gateway API support using Helm:

```bash
# Add the Cilium Helm repository
helm repo add cilium https://helm.cilium.io/

# Install Cilium with Gateway API enabled
helm install cilium cilium/cilium \
  --namespace kube-system \
  --set gatewayAPI.enabled=true \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=<your-kubernetes-api-server-ip> \
  --set k8sServicePort=6443
```

### Step 2: Install cert-manager

Install cert-manager to manage TLS certificates:

```bash
# install the default cert manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml
```

### Step 3: Create a ClusterIssuer for cert-manager

Create a ClusterIssuer for cert-manager to issue certificates:

```yaml
# cluster-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
```

Apply the ClusterIssuer:

```bash
kubectl apply -f cluster-issuer.yaml
```

### Step 4: Create a Wildcard Certificate for OpenCloud Domains

Create a wildcard certificate for all OpenCloud subdomains:

```yaml
# certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: opencloud-wildcard-tls
  namespace: kube-system
spec:
  secretName: opencloud-wildcard-tls
  dnsNames:
    - "opencloud.test"
    - "*.opencloud.test"
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
```

Apply the certificate:

```bash
kubectl apply -f certificate.yaml
```

### Step 4: Configure DNS

Configure your DNS to point to the Gateway IP address. You can use a wildcard DNS record or individual records for each service:

```
*.opencloud.test  IN  A  192.168.178.77  # Replace with your Gateway IP
```

Alternatively, for local testing, you can add entries to your `/etc/hosts` file:

```
192.168.178.77  cloud.opencloud.test
192.168.178.77  keycloak.opencloud.test
192.168.178.77  minio.opencloud.test
192.168.178.77  collabora.opencloud.test
192.168.178.77  collaboration.opencloud.test
192.168.178.77  wopiserver.opencloud.test
```

### Step 5: Install OpenCloud

Finally, install OpenCloud using Helm. This will create the necessary HTTPRoute
and Gateway resources:

```bash
helm install opencloud oci://ghcr.io/opencloud-eu/helm-charts/opencloud \
  --version 0.1.5 \
  --namespace opencloud \
  --create-namespace \
  --set httpRoute.enabled=true \
  --set httpRoute.gateway.create=true \
  --set httpRoute.gateway.className=cilium \
  --set httpRoute.gateway.annotations."io\.cilium/lb-ipam-ips"="192.168.178.77"
```

### Troubleshooting

If you encounter issues with the Collabora pod connecting to the WOPI server, ensure that:

1. The WOPI server certificate is properly created in the kube-system namespace
2. The Collabora pod is configured with the correct token settings in the configmap
3. The Gateway is properly configured to route traffic to the WOPI server
4. The ReferenceGrant is properly configured to allow the Gateway to access the TLS certificates

You can check the status of the certificates:

```bash
kubectl get certificates -n kube-system
```

Or check the logs of the Collabora pod:

```bash
kubectl logs -n opencloud -l app.kubernetes.io/component=collabora
```

You can also check the status of the HTTPRoutes:

```bash
kubectl get httproutes -n opencloud
```

## 📦 Development Chart

For a simplified development version of OpenCloud using a single Docker container, please refer to the [Development Chart Documentation](../opencloud-dev/README.md).

## 📜 License

This project is licensed under the **AGPLv3** licence. See the [LICENSE](../../LICENSE) file for more details.

## Community Maintained

This repository is **community-maintained** and **not officially supported by OpenCloud GmbH**. Use at your own risk, and feel free to contribute to improve the project!
