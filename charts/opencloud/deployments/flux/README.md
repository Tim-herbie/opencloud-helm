# FluxCD deployment for OpenCloud

Deploy OpenCloud with shared Keycloak + OpenLDAP + ClamAV using the
[Flux Operator](https://fluxoperator.dev/) `ResourceSet` CRD. One OpenCloud
chart, **N instances** (tenants) sharing the same Keycloak + OpenLDAP +
ClamAV — all four deployed by default. To use an external provider for any
of them, just skip its folder.

**Multi-cluster by design:** the same ResourceSet files run unchanged on
every cluster. Each cluster carries its identity (env + which OpenCloud
instances to run) in a local `ResourceSetInputProvider` CR; the operator
reads those providers and renders the right HelmReleases for that cluster.
No Kustomize overlays, no drift between clusters on the shared parts — the
only cluster-specific files live under `clusters/<env>/`.

> Replaces `deployments/helm/` (helmfile) and `deployments/timoni/`. Those
> folders are kept untouched until this Flux setup is validated end-to-end,
> after which they will be deleted.

## Layout

```
flux/
├── README.md
├── opencloud/                       One HelmRelease per instance (N tenants)
│   └── opencloud-rset.yaml         ResourceSet: inputsFrom a labelled ResourceSetInputProvider,
│                                    renders OCIRepository(prod) / local Git chart(test)
│                                    + one HelmRelease per instance
├── keycloak/                        Shared Keycloak (OIDC) — deployed by default; SKIP if external IdP
│   ├── keycloak-rset.yaml          ResourceSet: upstream HelmRepository (bitnami) + HelmRelease
│   └── values.yaml                 ConfigMap (non-secret, includes the OpenCloud realm JSON via extraDeploy)
├── openldap/                        Shared OpenLDAP — SKIP if external LDAP
│   ├── openldap-rset.yaml          ResourceSet: upstream HelmRepository + HelmRelease
│   └── values.yaml                 ConfigMap (non-secret)
├── clamav/                          Shared ClamAV — SKIP if external ClamAV
│   ├── clamav-rset.yaml            ResourceSet: upstream HelmRepository + HelmRelease
│   └── values.yaml                 ConfigMap (non-secret)
└── clusters/                        Per-cluster (env) files — apply ONLY your cluster's folder
    ├── test/
    │   ├── opencloud-oc1-inputs.yaml   Static ResourceSetInputProvider for oc1 @ test
    │   ├── keycloak-values.yaml        ConfigMap (env-specific, e.g. KC_HOSTNAME=keycloak.opencloud.test)
    │   ├── keycloak-secrets.example.yaml
    │   ├── openldap-values.yaml        ConfigMap (env-specific)
    │   ├── openldap-secrets.example.yaml
    │   ├── clamav-values.yaml          ConfigMap (env-specific)
    │   ├── opencloud-oc1-values.yaml   ConfigMap for the oc1 instance on this cluster
    │   └── opencloud-secrets.example.yaml
    └── prod/
        ├── opencloud-oc1-inputs.yaml   Static ResourceSetInputProvider for oc1 @ prod
        ├── keycloak-values.yaml
        ├── keycloak-secrets.example.yaml
        ├── openldap-values.yaml
        ├── openldap-secrets.example.yaml
        ├── clamav-values.yaml
        ├── opencloud-oc1-values.yaml
        └── opencloud-secrets.example.yaml
```

Two flavours of file:

- **Cluster-agnostic (root `flux/<chart>/`)** — the ResourceSets themselves.
  Same on every cluster; edit them to change behaviour for ALL clusters.
- **Cluster-specific (`flux/clusters/<env>/`)** — env-specific ConfigMaps,
  Secrets and the per-instance `ResourceSetInputProvider` CRs. Apply only
  your cluster's folder.

## One-command deploy (per cluster)

```bash
# From the repo root, on the cluster matching <env>:
kubectl apply -f charts/opencloud/deployments/flux/clusters/<env>/ \
              -f charts/opencloud/deployments/flux/opencloud/ \
              -f charts/opencloud/deployments/flux/keycloak/ \
              -f charts/opencloud/deployments/flux/openldap/ \
              -f charts/opencloud/deployments/flux/clamav/
```

This applies the per-cluster providers + ConfigMaps + Secrets first, then
the (shared) ResourceSets. The `*.example.yaml` Secrets carry **placeholder**
values — fine for a throwaway test cluster; for prod, create real secrets
out-of-band (see [Secrets](#secrets)) and skip the example files.

The shorter form `kubectl apply -R -f charts/opencloud/deployments/flux/`
also works but applies BOTH envs' ConfigMaps on the same cluster — only use
it on a single-cluster demo where you don't mind test+prod values colliding
(ConfigMap names are the same per chart, so the last-applied wins).

## Design

- **One ResourceSet per chart** (modular):
  - Apply only the files you need. Using an **external** Keycloak /
    OpenLDAP / ClamAV? Skip the corresponding folder entirely — no dangling
    Flux sources.
- **Multi-cluster with `ResourceSetInputProvider` (Static type)**:
  - The `opencloud` ResourceSet has no inline `spec.inputs`. Instead it
    references any `ResourceSetInputProvider` matching the labels
    `app.kubernetes.io/part-of=opencloud, app.kubernetes.io/component=opencloud-instance`
    via `spec.inputsFrom`.
  - Each cluster carries one Static provider per OpenCloud instance it
    should run (e.g. `clusters/test/opencloud-oc1-inputs.yaml`). The
    `defaultValues` carry `env`, `instance`, `namespace`, `domain`,
    `replicas` — that becomes one row in the ResourceSet's `inputs`.
  - The same `opencloud/opencloud-rset.yaml` runs on test and prod; the
    cluster-local providers decide which HelmRelease(s) get rendered. Zero
    drift on the shared ResourceSet template.
- **Shared infra, N OpenCloud instances**:
  - Keycloak, OpenLDAP and ClamAV each have a single HelmRelease (one shared
    service). Their ResourceSets use inline `inputs` (chart version + namespace)
    — no provider needed since they don't vary per cluster at the ResourceSet
    level (their env-specific VALUES come from ConfigMaps in `clusters/<env>/`).
  - Every OpenCloud instance reaches the shared Keycloak/OpenLDAP/ClamAV by
    DNS name — set in *its own* ConfigMap, so the OpenCloud ResourceSet has
    **no `dependsOn`** on the optional infra ResourceSets (avoids a Stalled
    ResourceSet when those are skipped for external services).
- **Config and secrets are not hardcoded** in any HelmRelease:
  - Non-secret config lives in ConfigMaps (`<chart>/values.yaml` shared +
    `clusters/<env>/<chart>-values.yaml` env-specific), injected via
    `.spec.valuesFrom: ConfigMap`.
  - Secrets live in real Secrets, injected via `.spec.valuesFrom: Secret`
    or read by the chart through its own `secretRef` (`ldap-bind-secrets`,
    `s3secret`).
- **Test = local chart, Prod = OCI**:
  - Input field `env: test` → `chart.spec.sourceRef.kind: GitRepository`
    pointing at the flux bootstrap `flux-system` GitRepository, path
    `./charts/opencloud`. Iterate locally, push to git, Flux reconciles.
  - Input field `env: prod` → `chartRef.kind: OCIRepository` pointing at
    `oci://ghcr.io/tim-herbie/opencloud-helm`, `ref.semver: ">=2.4.0"`.
  - The branch is handled with `resourcesTemplate` + `<< if eq $inst.env ... >>`.

## Prerequisite: the Flux Operator

Make sure the [flux-operator](https://fluxoperator.dev/docs/install/) and the
`ResourceSet`/`ResourceSetInputProvider` CRDs are installed, and that Flux
is bootstrapped on each target cluster so a `GitRepository` named
`flux-system` in namespace `flux-system` checks out **this repository**
(needed for the test chart path `./charts/opencloud`).

## Install (step by step, per cluster)

1. Create namespaces:
   ```bash
   kubectl create namespace opencloud openldap clamav
   ```
2. Apply your cluster's folder + the shared ResourceSets:
   ```bash
   ENV=test   # or 'prod' on the prod cluster
   kubectl apply -f charts/opencloud/deployments/flux/clusters/$ENV/ \
                 -f charts/opencloud/deployments/flux/opencloud/ \
                 -f charts/opencloud/deployments/flux/keycloak/ \
                 -f charts/opencloud/deployments/flux/openldap/ \
                 -f charts/opencloud/deployments/flux/clamav/
   ```
3. Watch:
   ```bash
   kubectl get resourceset,resourcesetinputprovider -A
   kubectl wait rsip/opencloud-${ENV}-oc1 -n flux-system --for=condition=ready --timeout=2m
   kubectl wait resourceset/opencloud -n flux-system --for=condition=ready --timeout=15m
   kubectl get helmrelease -A
   ```

## Secrets

Secrets are **never** committed with real values. The `*.example.yaml` files
carry placeholders only — safe for a test cluster. For real deployments,
create the secrets out-of-band (`kubectl create secret`, sealed-secrets,
external-secrets, sops, etc.) in the right namespace. Each HelmRelease
references them by fixed name via `spec.valuesFrom` / chart `secretRef`, so
the HelmRelease YAML stays value-free.

### 1. Keycloak — namespace `opencloud`
```bash
kubectl -n opencloud create secret generic keycloak-secrets \
  --from-literal=auth.adminUser=admin \
  --from-literal=auth.adminPassword='<CHANGE_ME>' \
  --from-literal=postgresql.auth.postgresPassword='<CHANGE_ME>' \
  --from-literal=postgresql.auth.username=keycloak \
  --from-literal=postgresql.auth.password='<CHANGE_ME>' \
  --from-literal=postgresql.auth.database=keycloak
```

### 2. OpenLDAP — namespace `openldap`
```bash
kubectl -n openldap create secret generic openldap-secrets \
  --from-literal=global.adminPassword='<CHANGE_ME>' \
  --from-literal=global.configPassword='<CHANGE_ME>'
```

### 3. OpenCloud chart secret refs — namespace `<instance>` (e.g. `opencloud`)
The OpenCloud chart reads two Secrets by name (set in the instance ConfigMap:
`secretRefs.ldapSecretRef: ldap-bind-secrets`, `secretRefs.s3CredentialsSecretRef: s3secret`). Create them in EACH OpenCloud instance namespace:
```bash
kubectl -n opencloud create secret generic ldap-bind-secrets \
  --from-literal=reva-ldap-bind-password='<CHANGE_ME>' \
  --from-literal=graph-ldap-bind-password='<CHANGE_ME>'

kubectl -n opencloud create secret generic s3secret \
  --from-literal=accessKey='<CHANGE_ME>' \
  --from-literal=secretKey='<CHANGE_ME>'
```

### 4. OpenCloud instance helmrelease values Secret (optional)
Each `opencloud-<instance>-secrets` Secret (referenced via `valuesFrom` on
the HelmRelease with `optional: true`) can carry any sensitive Helm value
you don't want in the ConfigMap — e.g. `opencloud.adminPassword`.
```bash
kubectl -n opencloud create secret generic opencloud-oc1-secrets \
  --from-literal=opencloud.adminPassword='<CHANGE_ME>'
```
> Repeat steps 3 & 4 per OpenCloud instance namespace.

## Add a new OpenCloud instance (tenant) on a cluster

1. Pick `instance`, `namespace`, `domain`, `replicas`. (env is fixed per
   cluster — but you can override per-instance if you really want.)
2. Copy `clusters/<env>/opencloud-oc1-inputs.yaml` →
   `clusters/<env>/opencloud-<NEW>-inputs.yaml`; change the metadata.name,
   `instance`, `namespace`, `domain`, `replicas`. Keep the labels.
3. Create the namespace and a `opencloud-<NEW>-values` ConfigMap in the new
   namespace (copy `opencloud-oc1-values.yaml`, rename, change
   `global.domain.opencloud`, etc.).
4. Create the instance Secrets (`ldap-bind-secrets`, `s3secret`,
   `opencloud-<NEW>-secrets`) in the new namespace.
5. On the cluster: `kubectl apply -f clusters/<env>/opencloud-<NEW>-inputs.yaml`.
   The operator picks up the new provider (it matches the label selector)
   and the `opencloud` ResourceSet re-renders, adding the new HelmRelease.

## Use external Keycloak / OpenLDAP / ClamAV

- Simply **don't apply** the corresponding folder (`keycloak/`, `openldap/`,
  `clamav/`) AND the matching `clusters/<env>/<chart>*.yaml` ConfigMaps.
- Edit the OpenCloud instance ConfigMap: point `oidc.issuerUrl`,
  `opencloud.ldap.uri`, `features.virusscan.clamavSocket` etc. at your
  external service FQDN/URL. The OpenCloud HelmRelease doesn't care where
  the service comes from — only the values do.

## Optional: enforce ordering when shared infra IS deployed by Flux

If you do deploy the shared infra via Flux and want OpenCloud instances to
wait for it, uncomment this in `opencloud/opencloud-rset.yaml`:

```yaml
spec:
  dependsOn:
    - apiVersion: fluxcd.controlplane.io/v1
      kind: ResourceSet
      name: keycloak
      namespace: flux-system
      ready: true
    - apiVersion: fluxcd.controlplane.io/v1
      kind: ResourceSet
      name: openldap
      namespace: flux-system
      ready: true
    - apiVersion: fluxcd.controlplane.io/v1
      kind: ResourceSet
      name: clamav
      namespace: flux-system
      ready: true
```

Leave it commented if you might run with external infra — otherwise the
OpenCloud ResourceSet would Stall waiting for objects that don't exist.