# OpenCloud Minimal Setup

This setup provides a simplified OpenCloud deployment using the integrated Identity Management (IDM) and local storage backend.

It disables external dependencies such as Keycloak, PostgreSQL, and S3-compatible object storage to create a lightweight deployment with fewer components and reduced operational complexity.

The configuration is intended for development environments, testing scenarios, and smaller installations where an external identity provider, database, or object storage service is not required.

Helm Values

## Deployment

Create the namespace and install OpenCloud using Helm:

```bash
helm install opencloud \
  oci://ghcr.io/tim-herbie/opencloud-helm/opencloud \
  --version 2.4.6 \
  --namespace opencloud \
  --create-namespace \
  -f opencloud-minimal-values.yaml