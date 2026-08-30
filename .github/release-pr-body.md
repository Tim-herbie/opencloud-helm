## Release 3.0.0

### Breaking Changes
- The chart no longer ships or manages bundled Keycloak, PostgreSQL, and MinIO resources.
- All internal templates for these components were removed.
- The chart now focuses on OpenCloud itself and expects identity/storage dependencies to be handled externally when needed.
- If you previously relied on bundled Keycloak/PostgreSQL/MinIO, you must migrate your setup before upgrading.

### Migration Notes
- Remove old values related to internal Keycloak/PostgreSQL/MinIO.
- Move to external services or to the current default architecture (integrated IDM and non-bundled dependencies).
- Re-check OIDC and storage values, because configuration structure and defaults changed.
- If you are using the httproutes with one gateway listener for all routes, please take a look on the values file. We added a new parameter to allow one exact listener for all httproutes and one prefix to generate listeners for each route.


Base: changes since 2.4.7.

OpenCloud version from values.yaml: 7.5.0

### Pull Requests
- [#162](https://github.com/Tim-herbie/opencloud-helm/pull/162) feat(httproute): allow exact sectionName overrides for external gateways
- [#161](https://github.com/Tim-herbie/opencloud-helm/pull/161) chore(deps): update docker.io/collabora/code docker tag to v26.04.3.1.1
- [#155](https://github.com/Tim-herbie/opencloud-helm/pull/155) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v7.5.0
- [#160](https://github.com/Tim-herbie/opencloud-helm/pull/160) chore(deps): update docker.io/alpine/openssl docker tag to v3.5.8
- [#159](https://github.com/Tim-herbie/opencloud-helm/pull/159) Feature: Move collaboration into the opencloud process
- [#157](https://github.com/Tim-herbie/opencloud-helm/pull/157) feat: extend csp yaml for epub reader iframe sytle loading
- [#153](https://github.com/Tim-herbie/opencloud-helm/pull/153) chore(deps): update oras-project/setup-oras action to v2
- [#154](https://github.com/Tim-herbie/opencloud-helm/pull/154) fix: add Flux reconciler RBAC for Keycloak
- [#152](https://github.com/Tim-herbie/opencloud-helm/pull/152) chore(ci): package and push every helm chart for the tag latest
- [#149](https://github.com/Tim-herbie/opencloud-helm/pull/149) fix: preserve proxy policies with role quotas
- [#150](https://github.com/Tim-herbie/opencloud-helm/pull/150) chore(deps): update opencloudeu/web-extensions docker tag to draw-io-2.2.0

### Changelog
## [3.0.0] - 2026-08-30

### Breaking Changes
- [#107](https://github.com/Tim-herbie/opencloud-helm/pull/107) feat: enable HTTPS, OIDC auth, Collabora, ClamAV, and OPA policies- #107

### Features
- [#162](https://github.com/Tim-herbie/opencloud-helm/pull/162) feat(httproute): allow exact sectionName overrides for external gateways
- [#157](https://github.com/Tim-herbie/opencloud-helm/pull/157) feat: extend csp yaml for epub reader iframe sytle loading

### Fixes
- [#154](https://github.com/Tim-herbie/opencloud-helm/pull/154) fix: add Flux reconciler RBAC for Keycloak
- [#149](https://github.com/Tim-herbie/opencloud-helm/pull/149) fix: preserve proxy policies with role quotas

### Chore / Docs / CI / Other
- [#161](https://github.com/Tim-herbie/opencloud-helm/pull/161) chore(deps): update docker.io/collabora/code docker tag to v26.04.3.1.1
- [#155](https://github.com/Tim-herbie/opencloud-helm/pull/155) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v7.5.0
- [#160](https://github.com/Tim-herbie/opencloud-helm/pull/160) chore(deps): update docker.io/alpine/openssl docker tag to v3.5.8
- [#153](https://github.com/Tim-herbie/opencloud-helm/pull/153) chore(deps): update oras-project/setup-oras action to v2
- [#152](https://github.com/Tim-herbie/opencloud-helm/pull/152) chore(ci): package and push every helm chart for the tag latest
- [#150](https://github.com/Tim-herbie/opencloud-helm/pull/150) chore(deps): update opencloudeu/web-extensions docker tag to draw-io-2.2.0
- [#159](https://github.com/Tim-herbie/opencloud-helm/pull/159) Feature: Move collaboration into the opencloud process
